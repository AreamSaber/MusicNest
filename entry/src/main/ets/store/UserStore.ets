import { UserInfo } from '../model/Models';

/**
 * UserStore - 用户状态管理（基于 AppStorage 持久化）
 */
export class UserStore {
  /**
   * 获取 Token
   */
  static getToken(): string {
    return AppStorage.get<string>('token') || '';
  }

  /**
   * 设置 Token
   */
  static setToken(token: string): void {
    AppStorage.setOrCreate('token', token);
  }

  /**
   * 是否已登录
   */
  static isLoggedIn(): boolean {
    const token = AppStorage.get<string>('token');
    return token !== null && token !== undefined && token.length > 0;
  }

  /**
   * 获取用户信息
   */
  static getUserInfo(): UserInfo | null {
    return AppStorage.get<UserInfo>('userInfo');
  }

  /**
   * 设置用户信息
   */
  static setUserInfo(info: UserInfo): void {
    AppStorage.setOrCreate('userInfo', info);
  }

  /**
   * 退出登录（清除所有用户数据）
   */
  static logout(): void {
    AppStorage.setOrCreate('token', '');
    AppStorage.setOrCreate('userInfo', null);
  }
}
