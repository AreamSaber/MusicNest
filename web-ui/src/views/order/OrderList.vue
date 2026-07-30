<template>
  <div>
    <div class="page-header"><h3>订单管理</h3></div>
    <el-card>
      <el-row :gutter="16" style="margin-bottom:16px">
        <el-col :span="6">
          <el-input v-model="keyword" placeholder="搜索订单号" clearable @change="fetchData" />
        </el-col>
        <el-col :span="18">
          <el-radio-group v-model="status" @change="fetchData">
            <el-radio-button value="">全部</el-radio-button>
            <el-radio-button value="pending">待审核</el-radio-button>
            <el-radio-button value="renting,pending,returning,overdue">进行中</el-radio-button>
            <el-radio-button value="overdue">逾期</el-radio-button>
            <el-radio-button value="completed">已完成</el-radio-button>
            <el-radio-button value="cancelled">已取消</el-radio-button>
          </el-radio-group>
        </el-col>
      </el-row>

      <el-table :data="list" v-loading="loading" stripe @row-click="row => $router.push('/orders/' + row.id)" style="cursor:pointer">
        <el-table-column prop="orderNo" label="订单号" width="180" />
        <el-table-column prop="instrumentName" label="乐器" min-width="130" />
        <el-table-column prop="rentDays" label="天数" width="60" />
        <el-table-column prop="totalAmount" label="金额" width="90" />
        <el-table-column label="状态" width="90"><template #default="{row}"><StatusTag :status="row.status"/></template></el-table-column>
        <el-table-column prop="startDate" label="起租日" width="110" />
        <el-table-column prop="endDate" label="预计归还" width="110" />
        <el-table-column label="操作" width="180">
          <template #default="{row}">
            <el-button v-if="row.status==='pending'" size="small" type="success" @click.stop="approve(row.id)">审核通过</el-button>
            <el-button v-if="row.status==='pending'" size="small" type="warning" @click.stop="rejectOrder(row.id)">驳回</el-button>
            <el-button v-if="row.status==='returning'" size="small" type="primary" @click.stop="completeReturn(row.id)">确认归还</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination :total="total" @change="pageChange" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { orderApi } from '@/api/order'
import type { RentalOrderVO } from '@/api/types'
import StatusTag from '@/components/StatusTag.vue'
import Pagination from '@/components/Pagination.vue'

const list = ref<RentalOrderVO[]>([])
const loading = ref(false)
const total = ref(0)
const keyword = ref('')
const status = ref('')
let page = 1, size = 10

onMounted(() => fetchData())

async function fetchData() {
  loading.value = true
  try {
    const res = await orderApi.getList({ page, size, keyword: keyword.value, status: status.value })
    if (res.data.data) { list.value = res.data.data.records; total.value = res.data.data.total }
  } finally { loading.value = false }
}

function pageChange(p: number, s: number) { page = p; size = s; fetchData() }

async function approve(id: number) {
  await orderApi.approve(id)
  ElMessage.success('审核通过')
  fetchData()
}

async function rejectOrder(id: number) {
  const { value } = await ElMessageBox.prompt('请输入驳回原因', '驳回订单')
  if (value !== undefined && value !== null) {
    await orderApi.reject(id, value)
    ElMessage.success('已驳回')
    fetchData()
  }
}

async function completeReturn(id: number) {
  await ElMessageBox.confirm('确认乐器已归还且验收无误？', '确认归还', { type: 'warning' })
  await orderApi.completeReturn(id, false)
  ElMessage.success('归还完成')
  fetchData()
}
</script>

<style scoped>
.page-header { margin-bottom: 16px; }
.page-header h3 { margin: 0; }
</style>
