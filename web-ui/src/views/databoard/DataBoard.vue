<template>
  <div>
    <div class="page-header"><h3>数据看板</h3></div>
    <el-row :gutter="16" v-loading="loading">
      <el-col :span="6"><el-card><el-statistic title="今日营收" :value="revenue.todayRevenue || 0" prefix="¥" /></el-card></el-col>
      <el-col :span="6"><el-card><el-statistic title="本月营收" :value="revenue.monthRevenue || 0" prefix="¥" /></el-card></el-col>
      <el-col :span="6"><el-card><el-statistic title="待审核订单" :value="pending.newOrders" /></el-card></el-col>
      <el-col :span="6"><el-card><el-statistic title="逾期订单" :value="pending.overdueOrders" /></el-card></el-col>
    </el-row>
    <el-row :gutter="16" style="margin-top:16px" v-loading="loading">
      <el-col :span="12">
        <el-card><template #header>营收趋势</template>
          <div ref="revenueChartRef" style="height:300px"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card><template #header>品类占比</template>
          <div ref="categoryChartRef" style="height:300px"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted, nextTick } from 'vue'
import { dashboardApi } from '@/api/dashboard'
import * as echarts from 'echarts'

const loading = ref(false)
const pending = reactive({ newOrders: 0, overdueOrders: 0 })
const revenue = reactive({ todayRevenue: 0, monthRevenue: 0 })
const revenueChartRef = ref<HTMLDivElement>()
const categoryChartRef = ref<HTMLDivElement>()
let revenueChart: echarts.ECharts | null = null
let categoryChart: echarts.ECharts | null = null

onMounted(async () => {
  loading.value = true
  try {
    const [pRes, rRes, sRes] = await Promise.all([
      dashboardApi.getPending(),
      dashboardApi.getRevenue('month'),
      dashboardApi.getRentalStats()
    ])
    if (pRes.data.data) Object.assign(pending, pRes.data.data)
    if (rRes.data.data) Object.assign(revenue, rRes.data.data)
    await nextTick()
    initCharts(sRes.data.data || { categories: [] })
  } catch { /* mock ok */ }
  loading.value = false
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  revenueChart?.dispose()
  categoryChart?.dispose()
})

function handleResize() {
  revenueChart?.resize()
  categoryChart?.resize()
}

function initCharts(stats: any) {
  if (revenueChartRef.value) {
    revenueChart = echarts.init(revenueChartRef.value)
    revenueChart.setOption({
      tooltip: { trigger: 'axis' },
      xAxis: { type: 'category', data: ['1月','2月','3月','4月','5月','6月'] },
      yAxis: { type: 'value' },
      series: [{
        type: 'line', data: stats.revenueTrend || [0,0,0,0,0,0],
        smooth: true, color: '#2e02e9', areaStyle: { color: 'rgba(46,2,233,0.1)' }
      }]
    })
  }
  if (categoryChartRef.value) {
    categoryChart = echarts.init(categoryChartRef.value)
    const catData = stats.categories || []
    categoryChart.setOption({
      tooltip: { trigger: 'item' },
      series: [{
        type: 'pie', radius: ['40%','70%'],
        color: ['#2e02e9','#503de4','#6a5bfe','#8b7dff','#ada0ff','#cfcbff'],
        data: catData.length > 0 ? catData : [{ name: '暂无数据', value: 1 }]
      }]
    })
  }
}
</script>

<style scoped>
.page-header { margin-bottom: 16px; } .page-header h3 { margin: 0; }
</style>
