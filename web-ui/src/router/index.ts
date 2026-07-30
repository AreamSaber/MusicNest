import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import axios from 'axios'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { public: true }
  },
  {
    path: '/setup',
    name: 'SetupPassword',
    component: () => import('@/views/SetupPassword.vue'),
    meta: { public: true }
  },
  {
    path: '/',
    component: () => import('@/layouts/Layout.vue'),
    redirect: '/dashboard',
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('@/views/dashboard/Dashboard.vue') },
      { path: 'orders', name: 'OrderList', component: () => import('@/views/order/OrderList.vue') },
      { path: 'orders/:id', name: 'OrderDetail', component: () => import('@/views/order/OrderDetail.vue'), props: true },
      { path: 'inventory', name: 'InstrumentList', component: () => import('@/views/inventory/InstrumentList.vue') },
      { path: 'inventory/add', name: 'InstrumentAdd', component: () => import('@/views/inventory/InstrumentForm.vue') },
      { path: 'inventory/:id/edit', name: 'InstrumentEdit', component: () => import('@/views/inventory/InstrumentForm.vue'), props: true },
      { path: 'work-orders', name: 'WorkOrderList', component: () => import('@/views/workorder/WorkOrderList.vue') },
      { path: 'work-orders/:id', name: 'WorkOrderDetail', component: () => import('@/views/workorder/WorkOrderDetail.vue'), props: true },
      { path: 'databoard', name: 'DataBoard', component: () => import('@/views/databoard/DataBoard.vue'), meta: { role: 'ROLE_ADMIN' } },
      { path: 'system/staff', name: 'StaffList', component: () => import('@/views/system/StaffList.vue'), meta: { role: 'ROLE_ADMIN' } },
      { path: 'system/config', name: 'SystemConfig', component: () => import('@/views/system/SystemConfig.vue'), meta: { role: 'ROLE_ADMIN' } }
    ]
  }
]

let emptyPwdChecked = false

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, _from, next) => {
  // 公开页面直接放行
  if (to.meta.public) {
    next()
    return
  }

  // 检查是否有空密码账号（全局只查一次）
  if (!emptyPwdChecked) {
    emptyPwdChecked = true
    try {
      const res = await axios.get('/api/v1/admin/check-passwords')
      if (res.data?.data?.hasEmpty) {
        next('/setup')
        return
      }
    } catch { /* 后端不可用时跳过 */ }
  }

  const authStore = useAuthStore()
  if (!authStore.isLoggedIn) {
    next('/login')
    return
  }
  if (to.meta.role && to.meta.role === 'ROLE_ADMIN' && !authStore.isAdmin) {
    next('/dashboard')
    return
  }
  next()
})

export default router
