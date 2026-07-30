<template>
  <el-container class="layout">
    <el-aside width="220px">
      <Sidebar />
    </el-aside>
    <el-container>
      <el-header height="56px">
        <div class="header-content">
          <span class="title">鸿音管家 管理后台</span>
          <el-dropdown trigger="click">
            <span class="user-info">
              {{ authStore.realName }} <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main>
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import { ArrowDown } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'
import Sidebar from './Sidebar.vue'

const router = useRouter()
const authStore = useAuthStore()

function handleLogout() {
  authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.layout { height: 100vh; }
.el-aside {
  background-color: #1d1e2c;
  overflow-x: hidden;
}
.el-header {
  background: #fff;
  border-bottom: 1px solid #e8e8e8;
}
.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
}
.title { font-weight: 600; color: #2e02e9; }
.user-info { cursor: pointer; display: flex; align-items: center; gap: 4px; }
.el-main {
  background: #f5f6fa;
  padding: 20px;
}
</style>
