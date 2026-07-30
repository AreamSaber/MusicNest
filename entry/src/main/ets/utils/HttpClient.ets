import { http } from '@kit.NetworkKit';
import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ApiResponse } from '../model/Models';

export class HttpClient {
  private baseUrl: string = 'http://10.0.2.2:8080/api/v1';
  private timeout: number = 15000;
  private useMock: boolean = false;

  setBaseUrl(url: string): void { this.baseUrl = url; }
  enableMock(enable: boolean): void { this.useMock = enable; }
  isMockEnabled(): boolean { return this.useMock; }

  private buildQueryString(params: Record<string, string | number>): string {
    const entries = Object.entries(params);
    if (entries.length === 0) return '';
    return '?' + entries.map(([k, v]) => encodeURIComponent(k) + '=' + encodeURIComponent(String(v))).join('&');
  }

  private mockResponse<T>(method: http.RequestMethod, url: string): ApiResponse<T> {
    if (url.includes('/instruments') && !url.includes('/recommend') && method === http.RequestMethod.GET) {
      return { code: 200, message: 'mock ok', data: { records: [], total: 0 } as unknown as T };
    }
    return { code: 200, message: 'mock ok', data: null };
  }

  async request<T>(method: http.RequestMethod, url: string, params?: object | null): Promise<ApiResponse<T>> {
    if (this.useMock) {
      console.info('HttpClient Mock: ' + method + ' ' + url);
      return this.mockResponse<T>(method, url);
    }

    const token: string | null = AppStorage.get<string>('token');
    let fullUrl = this.baseUrl + url;
    let body: string | undefined = undefined;

    if (method === http.RequestMethod.GET && params) {
      fullUrl += this.buildQueryString(params as Record<string, string | number>);
    } else if (params) {
      body = JSON.stringify(params);
    }

    const httpRequest = http.createHttp();
    try {
      const data: http.HttpResponse = await httpRequest.request(fullUrl, {
        method: method,
        header: {
          'Content-Type': 'application/json',
          'Authorization': token ? 'Bearer ' + token : ''
        },
        extraData: body,
        connectTimeout: this.timeout,
        readTimeout: this.timeout
      });

      const response: ApiResponse<T> = JSON.parse(data.result as string);
      if (response.code === 401) {
        AppStorage.setOrCreate('token', '');
        AppStorage.setOrCreate('userInfo', null);
        router.replaceUrl({ url: 'pages/Login' });
      }
      return response;
    } catch (err) {
      const error = err as BusinessError;
      console.error('HttpClient Error: ' + error.code + ' ' + error.message);
      return { code: 500, message: '网络异常，请稍后重试', data: null };
    } finally {
      httpRequest.destroy();
    }
  }

  async get<T>(url: string, params?: Record<string, string | number>): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.GET, url, params);
  }
  async post<T>(url: string, params?: object): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.POST, url, params);
  }
  async put<T>(url: string, params?: object): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.PUT, url, params);
  }
  async delete<T>(url: string, params?: object): Promise<ApiResponse<T>> {
    return this.request<T>(http.RequestMethod.DELETE, url, params);
  }
}

export const httpClient = new HttpClient();
