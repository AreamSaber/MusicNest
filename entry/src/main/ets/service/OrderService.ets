import { httpClient } from '../utils/HttpClient';
import { ApiResponse, RentalOrderVO } from '../model/Models';

/**
 * OrderService - 租赁订单相关 API
 */
export class OrderService {
  /**
   * 创建租赁订单
   */
  async createOrder(data: object): Promise<ApiResponse<RentalOrderVO>> {
    return httpClient.post('/orders', data);
  }

  /**
   * 订单列表
   */
  async getList(params: object): Promise<ApiResponse<{ records: RentalOrderVO[]; total: number }>> {
    return httpClient.get('/orders', params);
  }

  /**
   * 订单详情
   */
  async getDetail(id: number): Promise<ApiResponse<RentalOrderVO>> {
    return httpClient.get('/orders/' + id);
  }

  /**
   * 支付订单（模拟）
   */
  async payOrder(id: number): Promise<ApiResponse<null>> {
    return httpClient.post('/orders/' + id + '/pay');
  }

  /**
   * 续租申请
   */
  async renewOrder(id: number, months: number): Promise<ApiResponse<RentalOrderVO>> {
    return httpClient.post('/orders/' + id + '/renew', { months: months });
  }

  /**
   * 归还预约
   */
  async returnBooking(id: number, returnDate: string): Promise<ApiResponse<null>> {
    return httpClient.post('/orders/' + id + '/return-booking', { returnDate: returnDate });
  }

  /**
   * 取消订单
   */
  async cancelOrder(id: number, reason?: string): Promise<ApiResponse<null>> {
    return httpClient.put('/orders/' + id + '/cancel', { reason: reason });
  }
}

export const orderService = new OrderService();
