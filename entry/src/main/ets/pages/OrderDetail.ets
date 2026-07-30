import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { StatusBadge } from '../views/StatusBadge';
import { FeeLine } from '../views/FeeLine';
import { orderService } from '../service/OrderService';
import { RentalOrderVO } from '../model/Models';

/**
 * OrderDetail - 订单详情页
 */
@Entry
@Component
struct OrderDetail {
  @State order: RentalOrderVO | null = null;
  @State isLoading: boolean = true;
  private orderId: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    this.orderId = (params?.['id'] as number) || 0;
    this.loadDetail();
  }

  async loadDetail(): Promise<void> {
    try {
      const res = await orderService.getDetail(this.orderId);
      if (res.data) this.order = res.data;
    } catch (err) { console.error('Load order detail failed'); }
    this.isLoading = false;
  }

  build() {
    if (this.isLoading || !this.order) {
      Column() { LoadingProgress().width(40).height(40) }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
      return;
    }

    Column() {
      TopAppBar({ title: '订单详情', showBack: true })

      Scroll() {
        Column() {
          // 状态头
          Row() {
            Text(this.order!.status === 'renting' ? '✅' : this.order!.status === 'completed' ? '🏁' : '⏳')
              .fontSize(32)
            Column() {
              Text(this.getStatusTitle(this.order!.status))
                .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
              Text(this.getStatusDesc(this.order!.status))
                .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
            }
            .margin({ left: 12 }).alignItems(HorizontalAlign.Start)
            Blank()
            Text('订单号: ' + this.order!.orderNo)
              .fontSize($r('app.float.label_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })

          // 乐器信息
          Row() {
            Image(this.order!.coverImage || '')
              .width(80).height(80).objectFit(ImageFit.Cover).borderRadius(8)
            Column() {
              Text(this.order!.instrumentName)
                .fontSize($r('app.float.body_md_font_size')).fontWeight(FontWeight.Bold)
              Text('日租金: ¥' + this.order!.dailyPrice)
                .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ top: 4 })
            }
            .margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1)
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          .margin({ top: 12 })

          // 时间轴
          Column() {
            Text('租期时间轴')
              .fontSize($r('app.float.label_md_font_size')).fontColor($r('app.color.on_surface_variant'))
              .width('100%').margin({ bottom: 12 })

            TimelineItem({ title: '起租日期', time: this.order!.startDate, active: true })
            if (this.order!.status === 'completed' || this.order!.actualReturnDate) {
              TimelineItem({ title: '实际归还', time: this.order!.actualReturnDate || '', active: true })
            }
            if (this.order!.status === 'renting') {
              TimelineItem({ title: '使用中', time: '已租 ' + this.order!.rentDays + ' 天', active: true, isProgress: true })
            }
            TimelineItem({ title: '预计归还', time: this.order!.endDate, active: this.order!.status === 'completed' })
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          .margin({ top: 12 })

          // 费用明细
          Column() {
            Text('费用明细')
              .fontSize($r('app.float.label_md_font_size')).fontColor($r('app.color.on_surface_variant'))
              .width('100%').margin({ bottom: 12 })
            FeeLine({ label: '租金', value: '¥' + this.order!.rentAmount.toFixed(2) })
            FeeLine({ label: '押金', value: '¥' + this.order!.depositAmount.toFixed(2) })
            if (this.order!.lateFee > 0) FeeLine({ label: '滞纳金', value: '¥' + this.order!.lateFee.toFixed(2), color: $r('app.color.error') })
            Divider().margin({ top: 8, bottom: 8 })
            FeeLine({ label: '实付', value: '¥' + this.order!.totalAmount.toFixed(2), bold: true })
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          .margin({ top: 12 })

          Row().height(120)
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      // 底部操作栏（根据状态动态按钮）
      if (this.order!.status === 'renting') {
        Row() {
          Button('续租')
            .layoutWeight(1).height(48).borderRadius(14)
            .fontColor($r('app.color.primary')).backgroundColor($r('app.color.surface_container_lowest'))
            .border({ width: 1, color: $r('app.color.primary') })
            .onClick(() => router.pushUrl({ url: 'pages/OrderRenew', params: { orderId: this.orderId } }))
          Button('报修')
            .layoutWeight(1).height(48).borderRadius(14).margin({ left: 8 })
            .fontColor($r('app.color.error')).backgroundColor($r('app.color.surface_container_lowest'))
            .border({ width: 1, color: $r('app.color.error_container') })
            .onClick(() => router.pushUrl({
              url: 'pages/MaintenanceCreate',
              params: {
                orderId: this.orderId,
                instrumentId: this.order!.instrumentId,
                instrumentName: this.order!.instrumentName,
                orderNo: this.order!.orderNo
              }
            }))
          Button('预约归还')
            .layoutWeight(1).height(48).borderRadius(14).margin({ left: 8 })
            .fontColor(Color.White)
            .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
            .onClick(() => router.pushUrl({ url: 'pages/ReturnBooking', params: { orderId: this.orderId } }))
        }.width('100%').padding(16)
        .backgroundColor('rgba(249,249,255,0.8)').backdropBlur(20)
      }

      if (this.order!.status === 'completed') {
        Row() {
          Button('评价')
            .layoutWeight(1).height(48).borderRadius(14)
            .fontColor(Color.White)
            .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
            .onClick(() => router.pushUrl({ url: 'pages/ReviewCreate', params: { orderId: this.orderId, type: 'rental' } }))
        }.width('100%').padding(16)
        .backgroundColor('rgba(249,249,255,0.8)').backdropBlur(20)
      }
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }

  getStatusTitle(s: string): string {
    const map: Record<string, string> = { renting: '租赁中', returning: '待归还', completed: '已完成', cancelled: '已取消', overdue: '已逾期' };
    return map[s] || s;
  }
  getStatusDesc(s: string): string {
    const map: Record<string, string> = { renting: '请按时归还', returning: '等待门店确认', completed: '感谢你的租赁', cancelled: '', overdue: '请尽快归还' };
    return map[s] || '';
  }
}

@Component
struct TimelineItem {
  @Prop title: string = '';
  @Prop time: string = '';
  @Prop active: boolean = true;
  @Prop isProgress: boolean = false;

  build() {
    Row() {
      Circle()
        .width(this.active ? 10 : 8).height(this.active ? 10 : 8)
        .fill(this.active ? $r('app.color.primary') : $r('app.color.outline_variant'))
      Column() {
        Text(this.title).fontSize($r('app.float.body_md_font_size')).fontWeight(FontWeight.Bold).fontColor(this.active ? $r('app.color.on_surface') : $r('app.color.on_surface_variant'))
        Text(this.time).fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ top: 2 })
      }
      .margin({ left: 12 }).alignItems(HorizontalAlign.Start)
    }
    .width('100%').margin({ top: this.isProgress ? 0 : 12 })
  }
}

