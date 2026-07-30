import { httpClient } from '../utils/HttpClient';
import { ApiResponse, UserInfo } from '../model/Models';

/**
 * AuthService - 认证相关 API
 */
export class AuthService {
  /**
   * 发送短信验证码
   */
  async sendCode(phone: string): Promise<ApiResponse<null>> {
    return httpClient.post('/auth/send-code', { phone: phone });
  }

  /**
   * 手机号+验证码登录/注册
   */
  async login(phone: string, code: string): Promise<ApiResponse<{ token: string; userInfo: UserInfo }>> {
    const res = await httpClient.post('/auth/login', { phone: phone, code: code });
    if (res.data) {
      AppStorage.setOrCreate('token', res.data.token);
      AppStorage.setOrCreate('userInfo', res.data.userInfo);
    }
    return res;
  }

  /**
   * 华为账号一键登录
   */
  async huaweiLogin(authCode: string): Promise<ApiResponse<{ token: string; userInfo: UserInfo }>> {
    const res = await httpClient.post('/auth/huawei-login', { authCode: authCode });
    if (res.data) {
      AppStorage.setOrCreate('token', res.data.token);
      AppStorage.setOrCreate('userInfo', res.data.userInfo);
    }
    return res;
  }

  /**
   * 员工登录（本端不使用，保留接口）
   */
  async staffLogin(username: string, password: string): Promise<ApiResponse<{ token: string }>> {
    return httpClient.post('/auth/staff-login', { username: username, password: password });
  }

  /**
   * 退出登录
   */
  async logout(): Promise<void> {
    AppStorage.setOrCreate('token', '');
    AppStorage.setOrCreate('userInfo', null);
  }
}

export const authService = new AuthService();
