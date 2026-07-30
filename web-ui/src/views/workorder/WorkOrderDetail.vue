<template>
  <div v-loading="loading">
    <div class="page-header">
      <el-button @click="$router.back()" text>← 返回</el-button>
      <h3>工单详情</h3>
    </div>

    <el-card v-if="order" style="margin-bottom:16px">
      <template #header>
        <div style="display:flex;justify-content:space-between">
          <span>工单号: {{ order.orderNo }}</span>
          <span><StatusTag :status="order.status" /></span>
        </div>
      </template>

      <el-descriptions :column="2" border>
        <el-descriptions-item label="乐器">{{ order.instrumentName }}</el-descriptions-item>
        <el-descriptions-item label="紧急程度">
          <el-tag :type="order.urgency==='urgent'?'danger':''">{{ order.urgency==='urgent'?'紧急':'普通' }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="故障描述" :span="2">{{ order.faultDesc }}</el-descriptions-item>
        <el-descriptions-item v-if="order.assigneeName" label="负责人">{{ order.assigneeName }}</el-descriptions-item>
        <el-descriptions-item v-if="order.diagnosis" label="诊断">{{ order.diagnosis }}</el-descriptions-item>
        <el-descriptions-item v-if="order.repairContent" label="维修内容" :span="2">{{ order.repairContent }}</el-descriptions-item>
        <el-descriptions-item v-if="order.repairParts" label="更换配件">{{ order.repairParts }}</el-descriptions-item>
        <el-descriptions-item v-if="order.repairCost > 0" label="维修费用">¥{{ order.repairCost }}</el-descriptions-item>
      </el-descriptions>
    </el-card>

    <el-card style="margin-bottom:16px">
      <template #header>状态时间轴</template>
      <el-timeline>
        <el-timeline-item timestamp="已提交" color="#2e02e9">{{ order?.createdAt }}</el-timeline-item>
        <el-timeline-item v-if="assignedOrLater" timestamp="已派单" color="#e6a23c">已指派维修人员</el-timeline-item>
        <el-timeline-item v-if="repairingOrLater" timestamp="维修中" color="#f56c6c">{{ order?.diagnosis || '维修进行中' }}</el-timeline-item>
        <el-timeline-item v-if="checkingOrCompleted" timestamp="待验收" color="#e6a23c">等待用户确认</el-timeline-item>
        <el-timeline-item v-if="order?.status==='completed'" timestamp="已完成" color="#909399">{{ order?.completedAt }}</el-timeline-item>
      </el-timeline>
    </el-card>

    <div style="display:flex;gap:12px;justify-content:flex-end">
      <el-button v-if="order?.status==='assigned'" type="warning" @click="startRepair">开始维修</el-button>
      <el-button v-if="order?.status==='repairing'" type="primary" @click="dialogVisible=true">填写维修记录</el-button>
    </div>

    <el-dialog v-model="dialogVisible" title="维修记录" width="500px">
      <el-form :model="repairForm" label-width="80px">
        <el-form-item label="故障诊断"><el-input v-model="repairForm.diagnosis" type="textarea" /></el-form-item>
        <el-form-item label="维修内容"><el-input v-model="repairForm.repairContent" type="textarea" /></el-form-item>
        <el-form-item label="更换配件"><el-input v-model="repairForm.repairParts" /></el-form-item>
        <el-form-item label="维修费用"><el-input-number v-model="repairForm.repairCost" :min="0" :precision="2" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible=false">取消</el-button>
        <el-button type="primary" @click="completeRepair">确认完成</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { workOrderApi } from '@/api/workorder'
import type { MaintenanceOrderVO } from '@/api/types'
import StatusTag from '@/components/StatusTag.vue'

const route = useRoute()
const router = useRouter()
const order = ref<MaintenanceOrderVO | null>(null)
const loading = ref(false)
const dialogVisible = ref(false)
const repairForm = reactive({ diagnosis: '', repairContent: '', repairParts: '', repairCost: 0 })

const assignedOrLater = computed(() => order.value && ['assigned','repairing','checking','completed'].includes(order.value.status))
const repairingOrLater = computed(() => order.value && ['repairing','checking','completed'].includes(order.value.status))
const checkingOrCompleted = computed(() => order.value && ['checking','completed'].includes(order.value.status))

onMounted(async () => {
  loading.value = true
  const id = Number(route.params.id)
  const res = await workOrderApi.getDetail(id)
  if (res.data.data) order.value = res.data.data
  loading.value = false
})

async function startRepair() {
  if (!order.value) return
  await workOrderApi.startRepair(order.value.id)
  ElMessage.success('已开始维修')
  order.value.status = 'repairing'
}

async function completeRepair() {
  if (!order.value) return
  await workOrderApi.completeRepair(order.value.id, { ...repairForm })
  ElMessage.success('维修完成')
  dialogVisible.value = false
  router.back()
}
</script>

<style scoped>
.page-header { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
.page-header h3 { margin: 0; }
</style>
