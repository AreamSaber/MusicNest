<template>
  <div>
    <el-upload
      :action="uploadUrl"
      :headers="uploadHeaders"
      :multiple="multiple"
      :limit="limit"
      :accept="'image/jpeg,image/png,image/webp'"
      :before-upload="beforeUpload"
      :on-success="handleSuccess"
      :on-error="handleError"
      :file-list="fileList"
      list-type="picture-card"
    >
      <el-icon><Plus /></el-icon>
    </el-upload>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import type { UploadFile, UploadRawFile } from 'element-plus'

const props = withDefaults(defineProps<{
  limit?: number
  multiple?: boolean
}>(), {
  limit: 5,
  multiple: true
})

const emit = defineEmits<{
  (e: 'change', urls: string[]): void
}>()

const uploadUrl = '/api/v1/files/upload'
const uploadHeaders = computed(() => ({
  Authorization: 'Bearer ' + (localStorage.getItem('token') || '')
}))
const fileList = ref<UploadFile[]>([])

function beforeUpload(file: UploadRawFile) {
  const maxSize = 5 * 1024 * 1024
  if (file.size > maxSize) {
    ElMessage.error('图片大小不能超过 5MB')
    return false
  }
  const validTypes = ['image/jpeg', 'image/png', 'image/webp']
  if (!validTypes.includes(file.type)) {
    ElMessage.error('仅支持 jpg/png/webp 格式')
    return false
  }
  return true
}

function handleSuccess(response: any) {
  const urls = fileList.value
    .filter(f => f.response?.data?.url)
    .map(f => f.response.data.url)
  emit('change', urls)
}

function handleError() {
  ElMessage.error('上传失败')
}
</script>
