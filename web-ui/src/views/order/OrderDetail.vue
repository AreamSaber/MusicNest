<template>
  <div v-loading="loading">
    <div class="page-header">
      <el-button @click="$router.back()" text>← 返回</el-button>
      <h3>订单详情</h3>
    </div>

    <el-card v-if="order" style="margin-bottom:16px">
      <template #header>
        <div style="display:flex;justify-content:space-between;align-items:center">
          <span>订单号: {{ order.orderNo }}</span>
          <StatusTag :status="order.status" />
        </div>
      </template>

      <el-descriptions :column="3" border>
        <el-descriptions-item label="乐器">{{ order.instrumentName }}</el-descriptions-item>
        <el-descriptions-item label="租期">{{ order.startDate }} ~ {{ order.endDate }}</el-descriptions-item>
        <el-descriptions-item label="天数">{{ order.rentDays }}天</el-descriptions-item>
        <el-descriptions-item label="日租金">¥{{ order.dailyPrice }}</el-descriptions-item>
        <el-descriptions-item label="押金">¥{{ order.depositAmount }}</el-descriptions-item>
        <el-descriptions-item label="租金">¥{{ order.rentAmount }}</el-descriptions-item>
        <el-descriptions-item v-if="order.lateFee > 0" label="滞纳金">
          <span style="color:#f56c6c">¥{{ order.lateFee }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="实付金额"><strong style="color:#2e02e9">¥{{ order.totalAmount }}</strong></el-descriptions-item>
        <el-descriptions-item v-if="order.actualReturnDate" label="实际归还">{{ order.actualReturnDate }}</el-descriptions-item>
        <el-descriptions-item label="配送方式">{{ order.deliveryType === 'pickup' ? '自提' : '配送' }}</el-descriptions-item>
      </el-descriptions>

      <div v-if="order.remark" style="margin-top:16px;color:#999">备注: {{ order.remark }}</div>
    </el-card>

    <el-card v-if="order" style="margin-bottom:16px">
      <template #header><span>状态时间轴</span></template>
      <el-timeline>
        <el-timeline-item timestamp="下单" :color="statusColor('pending')">
          {{ order.createdAt }}
        </el-timeline-item>
        <el-timeline-item v-if="order.status !== 'pending'" timestamp="审核通过" color="#2e02e9">
          订单进入租赁中
        </el-timeline-item>
        <el-timeline-item v-if="['renting','returning','completed'].includes(order.status)" timestamp="租赁中" color="#67c23a">
          乐器使用中
        </el-timeline-item>
        <el-timeline-item v-if="['returning','completed'].includes(order.status)" timestamp="归还预约" color="#e6a23c">
          用户已预约归还
        </el-timeline-item>
        <el-timeline-item v-if="order.status === 'completed'" timestamp="已完成" color="#909399">
          {{ order.actualReturnDate || '' }} 归还验收通过
        </el-timeline-item>
      </el-timeline>
    </el-card>

    <div v-if="order" style="display:flex;gap:12px;justify-content:flex-end">
      <el-button v-if="order.status==='pending'" type="success" @click="approve">审核通过</el-button>
      <el-button v-if="order.status==='pending'" type="warning" @click="rejectOrder">驳回</el-button>
      <el-button v-if="order.status==='returning'||order.status==='renting'" type="primary" @click="completeReturn">确认归还</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { orderApi } from '@/api/order'
import type { RentalOrderVO } from '@/api/types'
import StatusTag from '@/components/StatusTag.vue'

const route = useRoute()
const router = useRouter()
const order = ref<RentalOrderVO | null>(null)
const loading = ref(false)

onMounted(async () => {
  const id = Number(route.params.id)
  if (id) {
    loading.value = true
    const res = await orderApi.getDetail(id)
    if (res.data.data) order.value = res.data.data
    loading.value = false
  }
})

function statusColor(s: string) { return s === 'completed' ? '#909399' : s === 'cancelled' ? '#f56c6c' : '#2e02e9' }

async function approve() {
  if (!order.value) return
  await orderApi.approve(order.value.id)
  ElMessage.success('审核通过')
  order.value.status = 'renting'
}

async function rejectOrder() {
  if (!order.value) return
  const { value } = await ElMessageBox.prompt('驳回原因', '驳回')
  if (value !== undefined && value !== null) {
    await orderApi.reject(order.value.id, value)
    ElMessage.success('已驳回')
    order.value.status = 'cancelled'
  }
}

async function completeReturn() {
  if (!order.value) return
  await ElMessageBox.confirm('确认归还验收无误？', '确认', { type: 'warning' })
  await orderApi.completeReturn(order.value.id, false)
  ElMessage.success('归还完成')
  router.back()
}
</script>

<style scoped>
.page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
.page-header h3 { margin: 0; }
</style>
