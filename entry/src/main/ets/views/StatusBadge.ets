/**
 * StatusBadge - 通用状态标签
 * 根据 status 自动映射颜色
 */
@Component
export struct StatusBadge {
  @Prop status: string = 'pending';

  private statusMap: Record<string, { label: string; bgColor: ResourceStr; textColor: ResourceStr }> = {
    'pending': { label: '待支付', bgColor: $r('app.color.error_container'), textColor: $r('app.color.error') },
    'renting': { label: '租赁中', bgColor: 'rgba(0, 83, 56, 0.1)', textColor: $r('app.color.tertiary') },
    'returning': { label: '待归还', bgColor: $r('app.color.surface_container_high'), textColor: $r('app.color.on_surface_variant') },
    'completed': { label: '已完成', bgColor: $r('app.color.surface_variant'), textColor: $r('app.color.outline') },
    'cancelled': { label: '已取消', bgColor: $r('app.color.surface_variant'), textColor: $r('app.color.outline') },
    'overdue': { label: '已逾期', bgColor: $r('app.color.error_container'), textColor: $r('app.color.error') },
    'available': { label: '可租', bgColor: 'rgba(0, 83, 56, 0.1)', textColor: $r('app.color.tertiary') },
    'rented': { label: '已租出', bgColor: $r('app.color.surface_variant'), textColor: $r('app.color.on_surface_variant') },
    'maintenance': { label: '维修中', bgColor: $r('app.color.surface_container_high'), textColor: $r('app.color.on_surface_variant') },
    // 工单状态
    'assigned': { label: '已派单', bgColor: $r('app.color.surface_container_high'), textColor: $r('app.color.primary') },
    'repairing': { label: '维修中', bgColor: 'rgba(46, 2, 233, 0.08)', textColor: $r('app.color.primary') },
    'checking': { label: '待验收', bgColor: $r('app.color.surface_container_high'), textColor: $r('app.color.on_surface_variant') },
  };

  build() {
    Text(this.statusMap[this.status]?.label || this.status)
      .fontSize($r('app.float.label_sm_font_size'))
      .fontWeight(FontWeight.Medium)
      .fontColor(this.statusMap[this.status]?.textColor || $r('app.color.on_surface_variant'))
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      .borderRadius(12)
      .backgroundColor(this.statusMap[this.status]?.bgColor || $r('app.color.surface_variant'))
  }
}
