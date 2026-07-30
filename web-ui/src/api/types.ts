// API 统一响应
export interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

// 分页响应
export interface PageResult<T> {
  records: T[]
  total: number
  page: number
  size: number
}

// 员工信息
export interface StaffInfo {
  id: number
  username: string
  realName: string
  phone: string
  role: string
  status: number
}

// 乐器
export interface InstrumentVO {
  id: number
  name: string
  category: string
  brand: string
  model: string
  serialNo: string
  conditionLevel: number
  description: string
  specs: string
  dailyPrice: number
  weeklyPrice: number
  monthlyPrice: number
  deposit: number
  purchasePrice?: number
  status: string
  applicableLevel: string
  coverImage: string
  avgRating: number
  reviewCount: number
  createdAt: string
}

// 租赁订单
export interface RentalOrderVO {
  id: number
  orderNo: string
  userId: number
  userPhone: string
  userNickname: string
  instrumentId: number
  instrumentName: string
  coverImage: string
  startDate: string
  endDate: string
  actualReturnDate: string
  rentDays: number
  dailyPrice: number
  depositAmount: number
  rentAmount: number
  lateFee: number
  totalAmount: number
  status: string
  deliveryType: string
  remark: string
  createdAt: string
  timeline: OrderTimelineItem[]
}

export interface OrderTimelineItem {
  title: string
  time: string
  description: string
  active: boolean
}

// 维修工单
export interface MaintenanceOrderVO {
  id: number
  orderNo: string
  rentalOrderId: number
  instrumentName: string
  userPhone: string
  faultDesc: string
  faultImages: string[]
  urgency: string
  status: string
  assigneeName: string
  diagnosis: string
  repairContent: string
  repairParts: string
  repairCost: number
  completedAt: string
  timeline: MaintenanceTimelineItem[]
  createdAt: string
}

export interface MaintenanceTimelineItem {
  title: string
  time: string
  description: string
  operator: string
}

// 仪表盘待处理摘要
export interface PendingSummary {
  newOrders: number
  pendingWorkOrders: number
  overdueOrders: number
}

// 营收概览
export interface RevenueOverview {
  todayRevenue: number
  weekRevenue: number
  monthRevenue: number
  compareLastWeek: number
  compareLastMonth: number
}

// 字典
export interface SysDict {
  id: number
  dictType: string
  dictKey: string
  dictValue: string
  sortOrder: number
  status: number
}

// 系统配置
export interface SysConfig {
  id: number
  configKey: string
  configValue: string
  description: string
}

// 分页查询参数
export interface PageQuery {
  page?: number
  size?: number
  keyword?: string
  status?: string
}
