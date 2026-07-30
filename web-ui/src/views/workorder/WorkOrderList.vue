<template>
  <div>
    <div class="page-header"><h3>工单管理</h3></div>
    <el-card>
      <el-row :gutter="16" style="margin-bottom:16px">
        <el-col :span="18">
          <el-radio-group v-model="status" @change="fetchData">
            <el-radio-button value="">全部</el-radio-button>
            <el-radio-button value="pending">待派单</el-radio-button>
            <el-radio-button value="assigned">已派单</el-radio-button>
            <el-radio-button value="repairing">维修中</el-radio-button>
            <el-radio-button value="checking">待验收</el-radio-button>
            <el-radio-button value="completed">已完成</el-radio-button>
          </el-radio-group>
        </el-col>
      </el-row>

      <el-table :data="list" v-loading="loading" stripe :row-class-name="rowClass">
        <el-table-column prop="orderNo" label="工单号" width="180" />
        <el-table-column prop="instrumentName" label="乐器" min-width="120" />
        <el-table-column prop="faultDesc" label="故障" min-width="150" show-overflow-tooltip />
        <el-table-column label="紧急" width="70">
          <template #default="{row}"><el-tag v-if="row.urgency==='urgent'" type="danger" size="small">紧急</el-tag></template>
        </el-table-column>
        <el-table-column label="状态" width="90"><template #default="{row}"><StatusTag :status="row.status"/></template></el-table-column>
        <el-table-column label="操作" width="180">
          <template #default="{row}">
            <el-button size="small" @click="$router.push('/work-orders/'+row.id)">详情</el-button>
            <el-button v-if="row.status==='pending'" size="small" type="primary" @click="assignDialog(row.id)">派单</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination :total="total" @change="pageChange" />

      <el-dialog v-model="dialogVisible" title="派单" width="400px">
        <el-select v-model="selectedStaff" placeholder="选择员工" style="width:100%">
          <el-option v-for="s in staffList" :key="s.id" :label="s.realName" :value="s.id" />
        </el-select>
        <template #footer>
          <el-button @click="dialogVisible=false">取消</el-button>
          <el-button type="primary" @click="confirmAssign" :disabled="!selectedStaff">确认派单</el-button>
        </template>
      </el-dialog>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { workOrderApi } from '@/api/workorder'
import { adminApi } from '@/api/admin'
import type { MaintenanceOrderVO, StaffInfo } from '@/api/types'
import StatusTag from '@/components/StatusTag.vue'
import Pagination from '@/components/Pagination.vue'

const list = ref<MaintenanceOrderVO[]>([])
const loading = ref(false)
const total = ref(0)
const status = ref('')
const dialogVisible = ref(false)
const selectedStaff = ref<number | null>(null)
const assignId = ref<number>(0)
const staffList = ref<StaffInfo[]>([])
let page = 1, size = 10

onMounted(async () => {
  await fetchData()
  const res = await adminApi.getStaffList({})
  if (res.data.data) staffList.value = res.data.data.records
})

async function fetchData() {
  loading.value = true
  try {
    const res = await workOrderApi.getList({ page, size, status: status.value })
    if (res.data.data) { list.value = res.data.data.records; total.value = res.data.data.total }
  } finally { loading.value = false }
}

function pageChange(p: number, s: number) { page = p; size = s; fetchData() }

function assignDialog(id: number) {
  assignId.value = id;
  selectedStaff.value = null;
  dialogVisible.value = true;
}

async function confirmAssign() {
  if (!selectedStaff.value) return
  await workOrderApi.assign(assignId.value, selectedStaff.value)
  ElMessage.success('派单成功')
  dialogVisible.value = false
  fetchData()
}

function rowClass({ row }: { row: MaintenanceOrderVO }) {
  return row.urgency === 'urgent' ? 'urgent-row' : ''
}
</script>

<style scoped>
.page-header { margin-bottom: 16px; } .page-header h3 { margin: 0; }
:deep(.urgent-row) { background-color: #fef0f0 !important; }
</style>
