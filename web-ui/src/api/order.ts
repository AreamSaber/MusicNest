import request from '@/utils/request'
import type { ApiResponse, PageResult, RentalOrderVO } from './types'

export const orderApi = {
  getList: (params: any) =>
    request.get<ApiResponse<PageResult<RentalOrderVO>>>('/orders', { params }),
  getDetail: (id: number) =>
    request.get<ApiResponse<RentalOrderVO>>('/orders/' + id),
  approve: (id: number) =>
    request.put<ApiResponse<null>>('/orders/' + id + '/approve'),
  reject: (id: number, reason?: string) =>
    request.put<ApiResponse<null>>('/orders/' + id + '/reject', { reason }),
  completeReturn: (id: number, hasDamage?: boolean) =>
    request.put<ApiResponse<null>>('/orders/' + id + '/complete-return', { hasDamage }),
  getOverdue: (params: any) =>
    request.get<ApiResponse<PageResult<RentalOrderVO>>>('/orders/overdue', { params })
}
