<template>
  <div>
    <div class="page-header"><h3>系统配置</h3></div>
    <el-card>
      <el-form label-width="120px">
        <el-form-item label="最大租赁月数">
          <el-input-number v-model="configs.rent_max_months" :min="1" :max="36" />
        </el-form-item>
        <el-form-item label="默认押金比例">
          <el-input-number v-model="configs.deposit_default_ratio" :min="0.1" :max="3" :precision="2" :step="0.1" />
        </el-form-item>
        <el-form-item label="滞纳金倍率">
          <el-input-number v-model="configs.late_fee_rate" :min="1" :max="5" :precision="1" :step="0.1" />
        </el-form-item>
        <el-form-item label="年折旧率">
          <el-input-number v-model="configs.depreciation_rate" :min="0.01" :max="0.5" :precision="2" :step="0.01" />
        </el-form-item>
        <el-form-item label="维修超时天数">
          <el-input-number v-model="configs.repair_timeout_days" :min="1" :max="30" />
        </el-form-item>
        <el-form-item label="待验收自动确认">
          <el-input-number v-model="configs.checking_auto_days" :min="1" :max="14" />
          <span style="margin-left:8px;color:#999">天</span>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="saveConfigs">保存配置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { adminApi } from '@/api/admin'

const configs = reactive<Record<string, any>>({
  rent_max_months: 12,
  deposit_default_ratio: 1.0,
  late_fee_rate: 1.5,
  depreciation_rate: 0.1,
  repair_timeout_days: 7,
  checking_auto_days: 3
})

onMounted(async () => {
  try {
    const res = await adminApi.getConfigs()
    if (res.data.data) {
      res.data.data.forEach((c: any) => {
        if (configs.hasOwnProperty(c.configKey)) {
          configs[c.configKey] = isNaN(Number(c.configValue)) ? c.configValue : Number(c.configValue)
        }
      })
    }
  } catch { /* mock ok */ }
})

async function saveConfigs() {
  const data: Record<string, string> = {}
  for (const key of Object.keys(configs)) {
    data[key] = String(configs[key])
  }
  await adminApi.updateConfigs(data)
  ElMessage.success('配置已保存')
}
</script>

<style scoped>
.page-header { margin-bottom: 16px; } .page-header h3 { margin: 0; }
</style>
