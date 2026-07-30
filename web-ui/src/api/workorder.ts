import request from '@/utils/request'
import type { ApiResponse, PageResult, MaintenanceOrderVO } from './types'

export const workOrderApi = {
  getList: (params: any) =>
    request.get<ApiResponse<PageResult<MaintenanceOrderVO>>>('/work-orders', { params }),
  getDetail: (id: number) =>
    request.get<ApiResponse<MaintenanceOrderVO>>('/work-orders/' + id),
  assign: (id: number, staffId: number) =>
    request.put<ApiResponse<null>>('/work-orders/' + id + '/assign', { staffId }),
  startRepair: (id: number) =>
    request.put<ApiResponse<null>>('/work-orders/' + id + '/start-repair'),
  completeRepair: (id: number, data: { diagnosis: string; repairContent: string; repairParts: string; repairCost: number }) =>
    request.put<ApiResponse<null>>('/work-orders/' + id + '/complete-repair', data)
}
