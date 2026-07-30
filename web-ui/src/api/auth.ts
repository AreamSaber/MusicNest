import request from '@/utils/request'
import type { ApiResponse, StaffInfo } from './types'

export const authApi = {
  staffLogin: (username: string, password: string) =>
    request.post<ApiResponse<{ token: string; staffInfo: StaffInfo }>>('/auth/staff-login', { username, password }),
  logout: () => request.get('/auth/logout')
}
