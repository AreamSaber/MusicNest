import { httpClient } from '../utils/HttpClient';
import { ApiResponse, UserInfo, NotificationVO } from '../model/Models';

/**
 * UserService - 用户相关 API
 */
export class UserService {
  /**
   * 获取个人信息
   */
  async getProfile(): Promise<ApiResponse<UserInfo>> {
    return httpClient.get('/user/profile');
  }

  /**
   * 更新个人信息
   */
  async updateProfile(data: object): Promise<ApiResponse<null>> {
    return httpClient.put('/user/profile', data);
  }

  /**
   * 提交实名认证
   */
  async submitVerification(realName: string, idCard: string, frontImage: string, backImage: string): Promise<ApiResponse<null>> {
    return httpClient.post('/user/verify', {
      realName: realName,
      idCard: idCard,
      idCardFront: frontImage,
      idCardBack: backImage
    });
  }

  /**
   * 获取信用分与明细
   */
  async getCreditScore(): Promise<ApiResponse<{ score: number; level: number; levelLabel: string; details: object[] }>> {
    return httpClient.get('/user/credit');
  }

  /**
   * 获取通知列表
   */
  async getNotifications(page: number = 1, size: number = 20): Promise<ApiResponse<{ records: NotificationVO[]; total: number }>> {
    return httpClient.get('/user/notifications', { page: page, size: size });
  }

  /**
   * 标记通知已读
   */
  async markNotificationRead(id: number): Promise<ApiResponse<null>> {
    return httpClient.put('/user/notifications/' + id + '/read');
  }
}

export const userService = new UserService();
