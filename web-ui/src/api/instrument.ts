import request from '@/utils/request'
import type { ApiResponse, PageResult, InstrumentVO } from './types'

export const instrumentApi = {
  getList: (params: any) =>
    request.get<ApiResponse<PageResult<InstrumentVO>>>('/instruments', { params }),
  getDetail: (id: number) =>
    request.get<ApiResponse<InstrumentVO>>('/instruments/' + id),
  create: (data: any) =>
    request.post<ApiResponse<InstrumentVO>>('/instruments', data),
  update: (id: number, data: any) =>
    request.put<ApiResponse<null>>('/instruments/' + id, data),
  updateStatus: (id: number, status: string) =>
    request.put<ApiResponse<null>>('/instruments/' + id + '/status', { status }),
  delete: (id: number) =>
    request.delete<ApiResponse<null>>('/instruments/' + id),
  uploadFile: (file: File, type: string) => {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('type', type)
    return request.post<ApiResponse<{ url: string }>>('/files/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
}
