import { httpClient } from '../utils/HttpClient';
import { ApiResponse, InstrumentVO } from '../model/Models';

/**
 * InstrumentService - 乐器相关 API
 */
export class InstrumentService {
  /**
   * 乐器列表（分页+筛选）
   */
  async getList(params: object): Promise<ApiResponse<{ records: InstrumentVO[]; total: number }>> {
    return httpClient.get('/instruments', params);
  }

  /**
   * 乐器详情
   */
  async getDetail(id: number): Promise<ApiResponse<InstrumentVO>> {
    return httpClient.get('/instruments/' + id);
  }

  /**
   * 热门乐器 TOP N
   */
  async getHot(limit: number = 6): Promise<ApiResponse<InstrumentVO[]>> {
    return httpClient.get('/instruments/hot', { limit: limit });
  }

  /**
   * 智能推荐（需登录）
   */
  async getRecommend(): Promise<ApiResponse<InstrumentVO[]>> {
    return httpClient.get('/instruments/recommend');
  }

  /**
   * 乐器评价列表
   */
  async getReviews(instrumentId: number, page: number = 1): Promise<ApiResponse<{ records: object[]; total: number }>> {
    return httpClient.get('/instruments/' + instrumentId + '/reviews', { page: page });
  }
}

export const instrumentService = new InstrumentService();
