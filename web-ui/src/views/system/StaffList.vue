<template>
  <div>
    <div class="page-header">
      <h3>员工管理</h3>
      <el-button type="primary" @click="openAdd">新增员工</el-button>
    </div>
    <el-card>
      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="username" label="账号" width="120" />
        <el-table-column prop="realName" label="姓名" width="100" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="role" label="角色" width="100">
          <template #default="{row}">{{ row.role==='ROLE_ADMIN'?'管理员':'员工' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{row}"><el-tag :type="row.status===1?'success':'danger'">{{ row.status===1?'启用':'禁用' }}</el-tag></template>
        </el-table-column>
        <el-table-column label="操作" width="220">
          <template #default="{row}">
            <el-button size="small" @click="toggleStatus(row)">{{ row.status===1?'禁用':'启用' }}</el-button>
            <el-button size="small" type="warning" @click="resetPwd(row.id)">重置密码</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination :total="total" @change="pageChange" />
    </el-card>

    <el-dialog v-model="dialogVisible" title="新增员工" width="400px">
      <el-form :model="form" label-width="80px" :rules="staffRules" ref="staffFormRef">
        <el-form-item label="账号" prop="username"><el-input v-model="form.username" /></el-form-item>
        <el-form-item label="姓名" prop="realName"><el-input v-model="form.realName" /></el-form-item>
        <el-form-item label="手机号" prop="phone"><el-input v-model="form.phone" /></el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="form.role" style="width:100%">
            <el-option label="员工" value="ROLE_STAFF" />
            <el-option label="管理员" value="ROLE_ADMIN" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible=false">取消</el-button>
        <el-button type="primary" @click="handleAdd">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { adminApi } from '@/api/admin'
import type { StaffInfo } from '@/api/types'
import Pagination from '@/components/Pagination.vue'

const staffFormRef = ref<FormInstance>()
const list = ref<StaffInfo[]>([])
const loading = ref(false)
const total = ref(0)
const dialogVisible = ref(false)
const form = reactive({ username: '', realName: '', phone: '', role: 'ROLE_STAFF' })

const staffRules: FormRules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }, { min: 2, max: 20, message: '2-20字符', trigger: 'blur' }],
  realName: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  phone: [{ pattern: /^1[3-9]\d{9}$/, message: '手机号格式错误', trigger: 'blur' }]
}
let page = 1, size = 10

onMounted(() => fetchData())

async function fetchData() {
  loading.value = true
  try {
    const res = await adminApi.getStaffList({ page, size })
    if (res.data.data) { list.value = res.data.data.records; total.value = res.data.data.total }
  } finally { loading.value = false }
}

function pageChange(p: number, s: number) { page = p; size = s; fetchData() }

async function handleAdd() {
  if (!staffFormRef.value) return
  await staffFormRef.value.validate(async (valid) => {
    if (!valid) return
    await adminApi.createStaff(form)
    ElMessage.success('员工已创建，默认密码 123456')
    dialogVisible.value = false
    fetchData()
  })
}

async function toggleStatus(row: StaffInfo) {
  await ElMessageBox.confirm('确认变更状态？', '提示', { type: 'warning' })
  await adminApi.updateStaffStatus(row.id, row.status === 1 ? 0 : 1)
  ElMessage.success('状态已更新')
  fetchData()
}

async function resetPwd(id: number) {
  await ElMessageBox.confirm('确认重置密码为 123456？', '提示', { type: 'warning' })
  await adminApi.resetStaffPwd(id)
  ElMessage.success('密码已重置')
}

function openAdd() { dialogVisible.value = true; form.username = ''; form.realName = ''; form.phone = ''; form.role = 'ROLE_STAFF'; staffFormRef.value?.resetFields() }
</script>

<style scoped>
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.page-header h3 { margin: 0; }
</style>
