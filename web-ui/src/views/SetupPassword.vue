<template>
  <div class="setup-container">
    <div class="setup-card">
      <h2>🎵 鸿音管家 — 初始设置</h2>
      <p class="subtitle">检测到以下 {{ accounts.length }} 个账号密码为空，请统一设置</p>

      <div class="account-list">
        <el-tag v-for="acc in accounts" :key="acc.id" type="info" style="margin:4px">
          {{ acc.realName }}（{{ acc.username }}）
        </el-tag>
      </div>

      <el-form style="margin-top:20px">
        <el-form-item label="统一密码" :error="errorMsg">
          <el-input
            v-model="password"
            type="password"
            show-password
            placeholder="请设置密码（至少6位）"
            size="large"
          />
        </el-form-item>
      </el-form>

      <el-button
        type="primary"
        size="large"
        :loading="loading"
        style="width:100%"
        @click="handleSubmit"
      >
        {{ loading ? '设置中...' : '确认设置' }}
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import axios from 'axios'

const router = useRouter()
const loading = ref(false)
const password = ref('')
const errorMsg = ref('')
const accounts = ref<Array<{ id: number; username: string; realName: string }>>([])

onMounted(async () => {
  try {
    const res = await axios.get('/api/v1/admin/check-passwords')
    if (res.data?.data?.hasEmpty) {
      accounts.value = res.data.data.accounts
    } else {
      router.push('/login')
    }
  } catch {
    ElMessage.error('无法连接到服务器')
  }
})

async function handleSubmit() {
  if (!password.value || password.value.length < 6) {
    errorMsg.value = '密码至少6位'
    return
  }
  errorMsg.value = ''
  loading.value = true
  try {
    const payload = accounts.value.map(acc => ({
      id: acc.id,
      password: password.value
    }))
    await axios.post('/api/v1/admin/setup-passwords', payload)
    ElMessage.success('密码设置成功！即将跳转登录页')
    setTimeout(() => router.push('/login'), 1500)
  } catch {
    ElMessage.error('设置失败，请重试')
  }
  loading.value = false
}
</script>

<style scoped>
.setup-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #4a3aff 0%, #6b5cff 100%);
}
.setup-card {
  width: 420px;
  padding: 40px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
}
.setup-card h2 { text-align: center; color: #2e02e9; margin: 0; }
.subtitle { text-align: center; color: #909399; margin: 12px 0 0; font-size: 14px; }
.account-list { text-align: center; margin-top: 20px; }
</style>
