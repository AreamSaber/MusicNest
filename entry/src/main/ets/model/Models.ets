/**
 * API 统一响应包装
 */
export class ApiResponse<T> {
  code: number = 0;
  message: string = '';
  data: T | null = null;
}

/**
 * 分页响应
 */
export class PageResult<T> {
  records: T[] = [];
  total: number = 0;
  page: number = 1;
  size: number = 10;
}

/**
 * 用户信息
 */
export class UserInfo {
  id: number = 0;
  phone: string = '';
  nickname: string = '';
  avatar: string = '';
  realName: string = '';
  idCard: string = '';
  verifyStatus: number = 0; // 0-未认证 1-审核中 2-已通过 3-已驳回
  creditScore: number = 600;
  creditLevel: number = 2; // 1-优秀 2-良好 3-一般 4-较差
  huaweiOpenId: string = '';
  createdAt: string = '';
}

/**
 * 乐器视图对象
 */
export class InstrumentVO {
  id: number = 0;
  name: string = '';
  category: string = '';
  brand: string = '';
  model: string = '';
  serialNo: string = '';
  conditionLevel: number = 3;
  description: string = '';
  specs: string = ''; // JSON string
  dailyPrice: number = 0;
  weeklyPrice: number = 0;
  monthlyPrice: number = 0;
  deposit: number = 0;
  status: string = 'available';
  applicableLevel: string = 'all';
  coverImage: string = '';
  images: string[] = [];
  avgRating: number = 0;
  reviewCount: number = 0;
  recommendReason: string = ''; // AI推荐理由
}

/**
 * 租赁订单视图对象
 */
export class RentalOrderVO {
  id: number = 0;
  orderNo: string = '';
  userId: number = 0;
  instrumentId: number = 0;
  instrumentName: string = '';
  coverImage: string = '';
  startDate: string = '';
  endDate: string = '';
  actualReturnDate: string = '';
  rentDays: number = 0;
  dailyPrice: number = 0;
  depositAmount: number = 0;
  rentAmount: number = 0;
  lateFee: number = 0;
  totalAmount: number = 0;
  status: string = 'pending';
  deliveryType: string = 'pickup';
  deliveryAddress: string = '';
  remark: string = '';
  cancelReason: string = '';
  parentOrderId: number = 0;
  createdAt: string = '';
  timeline: OrderTimelineItem[] = [];
}

export class OrderTimelineItem {
  title: string = '';
  time: string = '';
  description: string = '';
  active: boolean = false;
}

/**
 * 维修工单视图对象
 */
export class MaintenanceOrderVO {
  id: number = 0;
  orderNo: string = '';
  instrumentId: number = 0;
  instrumentName: string = '';
  coverImage: string = '';
  serialNo: string = '';
  faultDesc: string = '';
  faultImages: string[] = [];
  urgency: string = 'normal';
  status: string = 'pending';
  diagnosis: string = '';
  repairContent: string = '';
  repairParts: string = '';
  repairCost: number = 0;
  assigneeName: string = '';
  assigneeLevel: string = '';
  timeline: MaintenanceTimelineItem[] = [];
  createdAt: string = '';
}

export class MaintenanceTimelineItem {
  title: string = '';
  time: string = '';
  description: string = '';
  status: 'completed' | 'active' | 'pending' = 'pending';
}

/**
 * 评价视图对象
 */
export class ReviewVO {
  id: number = 0;
  userId: number = 0;
  userNickname: string = '';
  userAvatar: string = '';
  rentalOrderId: number = 0;
  instrumentId: number = 0;
  type: string = 'rental';
  rating: number = 0;
  content: string = '';
  images: string[] = [];
  createdAt: string = '';
}

/**
 * 支付记录
 */
export class PaymentVO {
  id: number = 0;
  orderId: number = 0;
  paymentNo: string = '';
  amount: number = 0;
  type: string = '';
  method: string = 'mock';
  status: string = 'pending';
  createdAt: string = '';
}

/**
 * 通知
 */
export class NotificationVO {
  id: number = 0;
  type: string = '';
  title: string = '';
  content: string = '';
  isRead: boolean = false;
  relatedId: number = 0;
  createdAt: string = '';
}
