<template>
  <div>
    <div class="page-header">
      <h3>库存管理</h3>
      <el-button type="primary" @click="$router.push('/inventory/add')">入库登记</el-button>
    </div>

    <el-card>
      <el-row :gutter="16" style="margin-bottom:16px">
        <el-col :span="6">
          <el-input v-model="keyword" placeholder="搜索名称/品牌" clearable @change="fetchData" />
        </el-col>
        <el-col :span="4">
          <el-select v-model="category" placeholder="分类" clearable @change="fetchData">
            <el-option v-for="c in categories" :key="c.key" :label="c.value" :value="c.key" />
          </el-select>
        </el-col>
        <el-col :span="4">
          <el-select v-model="status" placeholder="状态" clearable @change="fetchData">
            <el-option label="可租" value="available" />
            <el-option label="已租" value="rented" />
            <el-option label="维修中" value="maintenance" />
            <el-option label="已报废" value="scrapped" />
          </el-select>
        </el-col>
      </el-row>

      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="name" label="名称" min-width="140" />
        <el-table-column prop="brand" label="品牌" width="100" />
        <el-table-column prop="category" label="分类" width="80" />
        <el-table-column prop="conditionLevel" label="成色" width="70">
          <template #default="{ row }">{{ conditionLabels[row.conditionLevel] || row.conditionLevel }}</template>
        </el-table-column>
        <el-table-column prop="dailyPrice" label="日租" width="80" />
        <el-table-column prop="monthlyPrice" label="月租" width="80" />
        <el-table-column label="状态" width="90">
          <template #default="{ row }"><StatusTag :status="row.status" /></template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="$router.push('/inventory/' + row.id + '/edit')">编辑</el-button>
            <el-button v-if="row.status==='available'" size="small" type="warning" @click="changeStatus(row.id, 'maintenance')">标记维修</el-button>
            <el-button v-if="row.status!=='scrapped'" size="small" type="danger" @click="changeStatus(row.id, 'scrapped')">报废</el-button>
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
import { instrumentApi } from '@/api/instrument'
import type { InstrumentVO } from '@/api/types'
import StatusTag from '@/components/StatusTag.vue'
import Pagination from '@/components/Pagination.vue'

const list = ref<InstrumentVO[]>([])
const loading = ref(false)
const total = ref(0)
const keyword = ref('')
const category = ref('')
const status = ref('')
let page = 1, size = 10

const categories = [
  { key: 'piano', value: '钢琴' }, { key: 'guitar', value: '吉他' },
  { key: 'violin', value: '提琴' }, { key: 'wind', value: '管乐' },
  { key: 'folk', value: '民乐' }, { key: 'percussion', value: '打击乐' }
]
const conditionLabels: Record<number, string> = { 1: '全新', 2: '95新', 3: '9成新', 4: '8成新', 5: '较旧' }

onMounted(() => fetchData())

async function fetchData() {
  loading.value = true
  try {
    const res = await instrumentApi.getList({ page, size, keyword: keyword.value, category: category.value, status: status.value })
    if (res.data.data) {
      list.value = res.data.data.records
      total.value = res.data.data.total
    }
  } finally { loading.value = false }
}

function pageChange(p: number, s: number) { page = p; size = s; fetchData() }

async function changeStatus(id: number, st: string) {
  await ElMessageBox.confirm('确认变更状态？', '提示', { type: 'warning' })
  await instrumentApi.updateStatus(id, st)
  ElMessage.success('状态已更新')
  fetchData()
}
</script>

<style scoped>
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.page-header h3 { margin: 0; }
</style>
