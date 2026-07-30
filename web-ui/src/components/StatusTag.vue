<template>
  <el-tag :type="tagType" :effect="effect" size="small">
    {{ label }}
  </el-tag>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(defineProps<{
  status: string
  type?: 'order' | 'workorder'
  effect?: 'dark' | 'light' | 'plain'
}>(), {
  type: 'order',
  effect: 'light'
})

const statusMap: Record<string, { label: string; type: 'success' | 'warning' | 'danger' | 'info' | '' }> = {
  'pending': { label: props.type === 'workorder' ? '待派单' : '待审核', type: 'warning' },
  'renting': { label: '租赁中', type: 'success' },
  'returning': { label: '待归还', type: '' },
  'completed': { label: '已完成', type: 'info' },
  'cancelled': { label: '已取消', type: 'info' },
  'overdue': { label: '已逾期', type: 'danger' },
  'available': { label: '可租', type: 'success' },
  'rented': { label: '已租出', type: 'warning' },
  'maintenance': { label: '维修中', type: 'danger' },
  'scrapped': { label: '已报废', type: 'info' },
  'assigned': { label: '已派单', type: 'warning' },
  'repairing': { label: '维修中', type: 'danger' },
  'checking': { label: '待验收', type: 'warning' }
}

const current = computed(() => statusMap[props.status] || { label: props.status, type: '' as const })
const label = computed(() => current.value.label)
const tagType = computed(() => current.value.type || '')
</script>
