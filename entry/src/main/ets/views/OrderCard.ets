import { StatusBadge } from './StatusBadge';

/**
 * OrderCard - 订单卡片组件
 * 展示订单号、状态、乐器信息、租期、金额、操作按钮
 */
@Component
export struct OrderCard {
  @Prop orderNo: string = '';
  @Prop status: string = 'pending';
  @Prop instrumentName: string = '';
  @Prop imageUrl: string = '';
  @Prop startDate: string = '';
  @Prop endDate: string = '';
  @Prop totalAmount: number = 0;
  @Prop rentDays: number = 0;

  build() {
    Column() {
      // 顶部：订单号 + 状态
      Row() {
        Text('订单号: ' + this.orderNo)
          .fontSize($r('app.float.label_md_font_size'))
          .fontColor($r('app.color.on_surface_variant'))

        Blank()

        StatusBadge({ status: this.status })
      }
      .width('100%')
      .padding({ bottom: 8 })
      .border({ width: { bottom: 1 }, color: $r('app.color.surface_variant') })

      // 中间：乐器信息
      Row() {
        Image(this.imageUrl || '')
          .width(96)
          .height(96)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)

        Column() {
          Text(this.instrumentName)
            .fontSize($r('app.float.body_md_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_surface'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text('租期: ' + this.startDate + ' - ' + this.endDate + ' (' + this.rentDays + '天)')
            .fontSize($r('app.float.body_sm_font_size'))
            .fontColor($r('app.color.on_surface_variant'))
            .margin({ top: 4 })

          Blank()

          Text('¥' + this.totalAmount.toFixed(2))
            .fontSize($r('app.float.headline_md_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary'))
        }
        .layoutWeight(1)
        .height(96)
        .margin({ left: 12 })
      }
      .width('100%')
      .margin({ top: 8 })

      // 底部操作区 — 由父组件通过 slot 或条件渲染控制
    }
    .width('100%')
    .padding(16)
    .borderRadius(16)
    .backgroundColor($r('app.color.surface_container_lowest'))
    .shadow({
      radius: 20,
      color: 'rgba(30, 41, 59, 0.05)',
      offsetY: 4
    })
    .margin({ bottom: 12 })
  }
}
