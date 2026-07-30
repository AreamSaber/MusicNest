import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { orderService } from '../service/OrderService';

/**
 * ReturnBooking - 归还预约页
 */
@Entry
@Component
struct ReturnBooking {
  @State selectedDate: number = 0; // 偏移天数, 0=今天
  @State isLoading: boolean = false;
  private orderId: number = 0;
  private days: Array<{ label: string; date: string; disabled: boolean }> = [];

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    this.orderId = (params?.['orderId'] as number) || 0;
    this.generateDays();
  }

  generateDays(): void {
    const now = new Date();
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    for (let i = 0; i < 7; i++) {
      const d = new Date(now.getTime() + i * 86400000);
      this.days.push({
        label: i === 0 ? '今天' : weekdays[d.getDay()],
        date: (d.getMonth() + 1) + '/' + d.getDate(),
        disabled: false // 今天及未来7天均可选，PRD F-10: "不早于当前日期"
      });
    }
  }

  async submit(): Promise<void> {
    this.isLoading = true;
    try {
      const now = new Date();
      const returnDate = new Date(now.getTime() + this.selectedDate * 86400000);
      await orderService.returnBooking(this.orderId, returnDate.toISOString().split('T')[0]);
      router.back();
    } catch (err) { console.error('Booking failed'); }
    this.isLoading = false;
  }

  build() {
    Column() {
      TopAppBar({ title: '归还预约', showBack: true })

      Scroll() {
        Column() {
          // 日期选择器
          Text('选择归还日期')
            .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
            .width('100%').margin({ bottom: 12 })

          Row() {
            ForEach(this.days, (day: { label: string; date: string; disabled: boolean }, index: number) => {
              Column() {
                Text(day.label).fontSize($r('app.float.label_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
                Text(day.date)
                  .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
                  .fontColor(this.selectedDate === index ? $r('app.color.on_primary_container') : $r('app.color.on_surface'))
                  .margin({ top: 4 })
              }
              .width(64).height(80).borderRadius(12).justifyContent(FlexAlign.Center)
              .backgroundColor(this.selectedDate === index ? $r('app.color.primary_container') : $r('app.color.surface_container_lowest'))
              .border({ width: this.selectedDate === index ? 2 : 1, color: this.selectedDate === index ? $r('app.color.primary') : $r('app.color.outline_variant') })
              .margin({ right: 8 })
              .opacity(day.disabled ? 0.4 : 1.0)
              .enabled(!day.disabled)
              .onClick(() => { if (!day.disabled) this.selectedDate = index; })
            })
          }
          .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

          // 提示
          Row() {
            Text('ℹ️').fontSize(16).fontColor($r('app.color.on_surface_variant'))
            Text('请在营业时间 (10:00 - 20:00) 内将乐器归还至门店')
              .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ left: 8 })
          }
          .width('100%').padding(12).borderRadius(8)
          .backgroundColor($r('app.color.surface_container'))
          .margin({ top: 16 })

          // 门店信息
          Column() {
            Text('归还门店').fontSize($r('app.float.label_md_font_size')).fontColor($r('app.color.on_surface_variant')).width('100%').margin({ top: 24, bottom: 12 })
            Row() {
              Text('🏪').fontSize(32)
              Column() {
                Text('鸿音管家 - 朝阳大悦城店').fontSize($r('app.float.body_md_font_size')).fontWeight(FontWeight.Bold)
                Text('📍 北京市朝阳区朝阳北路101号 3层 L3-45').fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ top: 4 })
                Text('📞 400-888-9999').fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start).margin({ left: 12 })
            }
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })

          Row().height(120)
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      Button('提交预约')
        .width('100%').height(52).borderRadius(14)
        .fontSize($r('app.float.body_lg_font_size')).fontWeight(FontWeight.Bold).fontColor(Color.White)
        .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
        .margin(16)
        .enabled(!this.isLoading)
        .onClick(() => { this.submit(); })
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}
