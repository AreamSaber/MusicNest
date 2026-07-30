import { httpClient } from '../utils/HttpClient';
import { ApiResponse, MaintenanceOrderVO } from '../model/Models';

/**
 * WorkOrderService - 维修工单相关 API
 */
export class WorkOrderService {
  /**
   * 提交报修
   */
  async createWorkOrder(data: object): Promise<ApiResponse<MaintenanceOrderVO>> {
    return httpClient.post('/work-orders', data);
  }

  /**
   * 工单列表
   */
  async getList(params: object): Promise<ApiResponse<{ records: MaintenanceOrderVO[]; total: number }>> {
    return httpClient.get('/work-orders', params);
  }

  /**
   * 工单详情（含流转日志）
   */
  async getDetail(id: number): Promise<ApiResponse<MaintenanceOrderVO>> {
    return httpClient.get('/work-orders/' + id);
  }

  /**
   * 用户验收确认
   */
  async confirmRepair(id: number): Promise<ApiResponse<null>> {
    return httpClient.put('/work-orders/' + id + '/confirm');
  }
}

export const workOrderService = new WorkOrderService();
