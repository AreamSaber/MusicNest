<template>
  <div>
    <div class="page-header"><h3>工作台</h3></div>

    <el-row :gutter="16">
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card" @click="$router.push('/orders?status=pending')">
          <el-statistic title="待审核订单" :value="summary.newOrders">
            <template #prefix><el-icon :size="20"><Document /></el-icon></template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card" @click="$router.push('/work-orders')">
          <el-statistic title="待处理工单" :value="summary.pendingWorkOrders">
            <template #prefix><el-icon :size="20"><Tools /></el-icon></template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" class="stat-card" @click="$router.push('/orders?status=overdue')">
          <el-statistic title="逾期订单" :value="summary.overdueOrders">
            <template #prefix><el-icon :size="20" color="#f56c6c"><WarningFilled /></el-icon></template>
          </el-statistic>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="16" style="margin-top:24px">
      <el-col :span="8">
        <el-card shadow="hover" @click="$router.push('/orders')">
          <div class="quick-link">
            <el-icon :size="28" color="#2e02e9"><Document /></el-icon>
            <div><strong>订单管理</strong><p>审核 / 归还处理 / 逾期管理</p></div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" @click="$router.push('/inventory')">
          <div class="quick-link">
            <el-icon :size="28" color="#2e02e9"><Goods /></el-icon>
            <div><strong>库存管理</strong><p>入库 / 出库 / 状态变更</p></div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover" @click="$router.push('/work-orders')">
          <div class="quick-link">
            <el-icon :size="28" color="#2e02e9"><Tools /></el-icon>
            <div><strong>工单管理</strong><p>派单 / 维修 / 验收</p></div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row v-if="authStore.isAdmin" :gutter="16" style="margin-top:16px">
      <el-col :span="12">
        <el-card shadow="hover" @click="$router.push('/databoard')">
          <div class="quick-link">
            <el-icon :size="28" color="#503de4"><DataAnalysis /></el-icon>
            <div><strong>数据看板</strong><p>营收 / 统计 / 图表</p></div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="hover" @click="$router.push('/system/staff')">
          <div class="quick-link">
            <el-icon :size="28" color="#503de4"><Setting /></el-icon>
            <div><strong>系统管理</strong><p>员工 / 字典 / 配置</p></div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { reactive, onMounted } from 'vue'
import { Document, Tools, WarningFilled, Goods, DataAnalysis, Setting } from '@element-plus/icons-vue'
import { dashboardApi } from '@/api/dashboard'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const summary = reactive({ newOrders: 0, pendingWorkOrders: 0, overdueOrders: 0 })

onMounted(async () => {
  try {
    const res = await dashboardApi.getPending()
    if (res.data.data) Object.assign(summary, res.data.data)
  } catch { /* mock mode ok */ }
})
</script>

<style scoped>
.page-header { margin-bottom: 16px; } .page-header h3 { margin: 0; }
.stat-card { cursor: pointer; }
.quick-link { display: flex; align-items: center; gap: 16px; cursor: pointer; }
.quick-link p { margin: 4px 0 0; font-size: 12px; color: #909399; }
</style>
