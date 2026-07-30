<template>
  <div class="pagination-wrapper">
    <el-pagination
      v-model:current-page="currentPage"
      v-model:page-size="currentSize"
      :total="total"
      :page-sizes="[10, 20, 50]"
      layout="total, sizes, prev, pager, next, jumper"
      background
      @size-change="handleSizeChange"
      @current-change="handlePageChange"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

const props = withDefaults(defineProps<{
  total: number
  page?: number
  size?: number
}>(), {
  page: 1,
  size: 10
})

const emit = defineEmits<{
  (e: 'change', page: number, size: number): void
}>()

const currentPage = ref(props.page)
const currentSize = ref(props.size)

watch(() => props.page, (v) => { currentPage.value = v })
watch(() => props.size, (v) => { currentSize.value = v })

function handlePageChange(p: number) { emit('change', p, currentSize.value) }
function handleSizeChange(s: number) { emit('change', 1, s) }
</script>

<style scoped>
.pagination-wrapper {
  display: flex;
  justify-content: center;
  padding: 16px 0;
}
</style>
