/**
 * BottomNavBar - 底部四 Tab 导航栏（玻璃态）
 * Tab: 首页 / 分类 / 订单 / 我的
 */
@Component
export struct BottomNavBar {
  @Prop activeTab: number = 0;
  onChange?: (index: number) => void;

  private tabs: Array<{ label: string; icon: string }> = [
    { label: '首页', icon: '🏠' },
    { label: '分类', icon: '📂' },
    { label: '订单', icon: '📋' },
    { label: '我的', icon: '👤' }
  ];

  build() {
    Row() {
      ForEach(this.tabs, (tab: { label: string; icon: string }, index: number) => {
        Column() {
          Text(tab.icon)
            .fontSize(22)
            .margin({ bottom: 2 })

          Text(tab.label)
            .fontSize($r('app.float.label_md_font_size'))
            .fontWeight(FontWeight.Medium)
        }
        .width('25%')
        .padding({ top: 8, bottom: 4 })
        .borderRadius(16)
        .backgroundColor(index === this.activeTab ? $r('app.color.primary_container') : Color.Transparent)
        .fontColor(index === this.activeTab ? $r('app.color.on_primary_container') : $r('app.color.on_surface_variant'))
        .onClick(() => {
          if (this.onChange) {
            this.onChange(index);
          }
        })
      })
    }
    .width('100%')
    .height(64)
    .padding({ bottom: 8 })
    .backgroundColor('rgba(249, 249, 255, 0.6)')
    .backdropBlur(20)
    .borderRadius({ topLeft: 16, topRight: 16 })
    .shadow({
      radius: 20,
      color: 'rgba(30, 41, 59, 0.05)',
      offsetY: -4
    })
  }
}
