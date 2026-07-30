import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { StaffInfo } from '@/api/types'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string>(localStorage.getItem('token') || '')
  const staffInfo = ref<StaffInfo | null>(
    JSON.parse(localStorage.getItem('staffInfo') || 'null')
  )

  const isLoggedIn = computed(() => !!token.value)
  const isAdmin = computed(() => staffInfo.value?.role === 'ROLE_ADMIN')
  const realName = computed(() => staffInfo.value?.realName || '')

  function setAuth(t: string, info: StaffInfo) {
    token.value = t
    staffInfo.value = info
    localStorage.setItem('token', t)
    localStorage.setItem('staffInfo', JSON.stringify(info))
  }

  function logout() {
    token.value = ''
    staffInfo.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('staffInfo')
  }

  return { token, staffInfo, isLoggedIn, isAdmin, realName, setAuth, logout }
})
