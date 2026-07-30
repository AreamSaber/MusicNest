<template>
  <div>
    <div class="page-header">
      <h3>{{ isEdit ? '编辑乐器' : '入库登记' }}</h3>
    </div>
    <el-card>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="名称" prop="name"><el-input v-model="form.name" /></el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="分类" prop="category">
              <el-select v-model="form.category" style="width:100%">
                <el-option v-for="c in categories" :key="c.key" :label="c.value" :value="c.key" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="品牌" prop="brand"><el-input v-model="form.brand" /></el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="8">
            <el-form-item label="型号"><el-input v-model="form.model" /></el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="序列号"><el-input v-model="form.serialNo" /></el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="成色">
              <el-select v-model="form.conditionLevel" style="width:100%">
                <el-option v-for="i in 5" :key="i" :label="['全新','95新','9成新','8成新','较旧'][i-1]" :value="i" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="6">
            <el-form-item label="日租金" prop="dailyPrice"><el-input-number v-model="form.dailyPrice" :min="0" :precision="2" style="width:100%" /></el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="周租金"><el-input-number v-model="form.weeklyPrice" :min="0" :precision="2" style="width:100%" /></el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="月租金"><el-input-number v-model="form.monthlyPrice" :min="0" :precision="2" style="width:100%" /></el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="押金" prop="deposit"><el-input-number v-model="form.deposit" :min="0" :precision="2" style="width:100%" /></el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="16">
          <el-col :span="8">
            <el-form-item label="购入价值"><el-input-number v-model="form.purchasePrice" :min="0" :precision="2" style="width:100%" /></el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="适用人群">
              <el-select v-model="form.applicableLevel" style="width:100%">
                <el-option label="入门" value="beginner" />
                <el-option label="进阶" value="intermediate" />
                <el-option label="专业" value="professional" />
                <el-option label="全部" value="all" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="描述"><el-input v-model="form.description" type="textarea" :rows="3" /></el-form-item>
        <el-form-item label="规格参数"><el-input v-model="form.specs" placeholder='JSON格式，如 {"材质":"云杉木","尺寸":"4/4"}' /></el-form-item>
        <el-form-item label="封面图"><ImageUpload :limit="1" :multiple="false" @change="onCoverChange" /></el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="handleSubmit">{{ isEdit ? '保存修改' : '确认入库' }}</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { instrumentApi } from '@/api/instrument'
import type { FormInstance, FormRules } from 'element-plus'
import ImageUpload from '@/components/ImageUpload.vue'

const route = useRoute()
const router = useRouter()
const formRef = ref<FormInstance>()
const submitting = ref(false)
const isEdit = computed(() => !!route.params.id)

const form = reactive({
  name: '', category: '', brand: '', model: '', serialNo: '',
  conditionLevel: 3, dailyPrice: 0, weeklyPrice: 0, monthlyPrice: 0,
  deposit: 0, purchasePrice: 0, applicableLevel: 'all',
  description: '', specs: '', coverImage: ''
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入名称' }],
  category: [{ required: true, message: '请选择分类' }],
  brand: [{ required: true, message: '请输入品牌' }],
  dailyPrice: [{ required: true, message: '请输入日租金' }],
  deposit: [{ required: true, message: '请输入押金' }]
}

const categories = [
  { key: 'piano', value: '钢琴' }, { key: 'guitar', value: '吉他' },
  { key: 'violin', value: '提琴' }, { key: 'wind', value: '管乐' },
  { key: 'folk', value: '民乐' }, { key: 'percussion', value: '打击乐' }
]

function onCoverChange(urls: string[]) { form.coverImage = urls[0] || '' }

onMounted(async () => {
  if (isEdit.value) {
    const id = Number(route.params.id)
    const res = await instrumentApi.getDetail(id)
    if (res.data.data) Object.assign(form, res.data.data)
  }
})

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    submitting.value = true
    try {
      if (isEdit.value) {
        await instrumentApi.update(Number(route.params.id), form)
      } else {
        await instrumentApi.create(form)
      }
      ElMessage.success(isEdit.value ? '保存成功' : '入库成功')
      router.push('/inventory')
    } finally { submitting.value = false }
  })
}
</script>

<style scoped>
.page-header h3 { margin: 0 0 16px 0; }
</style>
