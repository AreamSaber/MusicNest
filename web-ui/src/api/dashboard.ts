import request from '@/utils/request'
import type { ApiResponse, PendingSummary, RevenueOverview } from './types'

export const dashboardApi = {
  getPending: () =>
    request.get<ApiResponse<PendingSummary>>('/dashboard/pending'),
  getRevenue: (period: string = 'month') =>
    request.get<ApiResponse<RevenueOverview>>('/dashboard/revenue', { params: { period } }),
  getRentalStats: () =>
    request.get<ApiResponse<any>>('/dashboard/rental-stats'),
  getUserStats: () =>
    request.get<ApiResponse<any>>('/dashboard/user-stats'),
  getWorkOrderStats: () =>
    request.get<ApiResponse<any>>('/dashboard/workorder-stats')
}
