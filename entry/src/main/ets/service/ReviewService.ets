import { httpClient } from '../utils/HttpClient';
import { ApiResponse, ReviewVO } from '../model/Models';

/**
 * ReviewService - 评价相关 API
 */
export class ReviewService {
  /**
   * 提交评价
   */
  async createReview(data: object): Promise<ApiResponse<ReviewVO>> {
    return httpClient.post('/reviews', data);
  }

  /**
   * 评价列表
   */
  async getList(params: object): Promise<ApiResponse<{ records: ReviewVO[]; total: number }>> {
    return httpClient.get('/reviews', params);
  }
}

export const reviewService = new ReviewService();
