<template>
  <div class="sidebar">
    <div class="logo">🎵 鸿音管家</div>
    <el-menu
      :default-active="activeRoute"
      router
      background-color="#1d1e2c"
      text-color="#a0a4b8"
      active-text-color="#6b5cff"
    >
      <el-menu-item index="/dashboard">
        <el-icon><Odometer /></el-icon><span>工作台</span>
      </el-menu-item>
      <el-menu-item index="/orders">
        <el-icon><Document /></el-icon><span>订单管理</span>
      </el-menu-item>
      <el-menu-item index="/inventory">
        <el-icon><Goods /></el-icon><span>库存管理</span>
      </el-menu-item>
      <el-menu-item index="/work-orders">
        <el-icon><Tools /></el-icon><span>工单管理</span>
      </el-menu-item>
      <template v-if="authStore.isAdmin">
        <el-menu-item index="/databoard">
          <el-icon><DataAnalysis /></el-icon><span>数据看板</span>
        </el-menu-item>
        <el-sub-menu index="system">
          <template #title>
            <el-icon><Setting /></el-icon><span>系统管理</span>
          </template>
          <el-menu-item index="/system/staff">员工管理</el-menu-item>
          <el-menu-item index="/system/config">系统配置</el-menu-item>
        </el-sub-menu>
      </template>
    </el-menu>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { Odometer, Document, Goods, Tools, DataAnalysis, Setting } from '@element-plus/icons-vue'

const route = useRoute()
const authStore = useAuthStore()
const activeRoute = computed(() => route.path)
</script>

<style scoped>
.sidebar { height: 100%; display: flex; flex-direction: column; }
.logo {
  height: 56px; line-height: 56px; text-align: center;
  color: #fff; font-size: 18px; font-weight: 600;
  border-bottom: 1px solid rgba(255,255,255,0.08);
}
.el-menu { border-right: none; flex: 1; }
</style>
