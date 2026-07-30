import request from '@/utils/request'
import type { ApiResponse, PageResult, StaffInfo, SysDict, SysConfig } from './types'

export const adminApi = {
  getStaffList: (params: any) =>
    request.get<ApiResponse<PageResult<StaffInfo>>>('/admin/staff', { params }),
  createStaff: (data: any) =>
    request.post<ApiResponse<StaffInfo>>('/admin/staff', data),
  updateStaff: (id: number, data: any) =>
    request.put<ApiResponse<null>>('/admin/staff/' + id, data),
  updateStaffStatus: (id: number, status: number) =>
    request.put<ApiResponse<null>>('/admin/staff/' + id + '/status', { status }),
  resetStaffPwd: (id: number) =>
    request.put<ApiResponse<null>>('/admin/staff/' + id + '/reset-pwd'),
  getDicts: (type?: string) =>
    request.get<ApiResponse<SysDict[]>>('/admin/dicts', { params: { type } }),
  createDict: (data: any) =>
    request.post<ApiResponse<SysDict>>('/admin/dicts', data),
  updateDict: (id: number, data: any) =>
    request.put<ApiResponse<null>>('/admin/dicts/' + id, data),
  getConfigs: () =>
    request.get<ApiResponse<SysConfig[]>>('/admin/configs'),
  updateConfigs: (data: Record<string, string>) =>
    request.put<ApiResponse<null>>('/admin/configs', data)
}
