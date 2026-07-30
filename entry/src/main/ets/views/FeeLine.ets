/**
 * FeeLine - 费用明细行组件（共享，OrderCreate/OrderDetail/OrderRenew 复用）
 */
@Component
export struct FeeLine {
  @Prop label: string = '';
  @Prop value: string = '';
  @Prop bold: boolean = false;
  @Prop color: ResourceStr = $r('app.color.on_surface');

  build() {
    Row() {
      Text(this.label)
        .fontSize($r('app.float.body_sm_font_size'))
        .fontColor($r('app.color.on_surface_variant'))
      Blank()
      Text(this.value)
        .fontSize(this.bold ? $r('app.float.headline_sm_font_size') : $r('app.float.body_md_font_size'))
        .fontWeight(this.bold ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.color)
    }
    .width('100%')
    .margin({ top: 6 })
  }
}
