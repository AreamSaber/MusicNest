import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { FeeLine } from '../views/FeeLine';
import { orderService } from '../service/OrderService';

/**
 * OrderRenew - 续租申请页
 */
@Entry
@Component
struct OrderRenew {
  @State selectedMonths: number = 3;
  @State isLoading: boolean = false;
  @State basePrice: number = 500;
  private orderId: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    this.orderId = (params?.['orderId'] as number) || 0;
    if (params?.['basePrice']) this.basePrice = (params?.['basePrice'] as number);
  }

  get baseRent(): number { return this.basePrice * this.selectedMonths; }
  get discountRate(): number {
    if (this.selectedMonths >= 6) return 0.9;
    if (this.selectedMonths >= 3) return 0.95;
    return 1;
  }
  get discountAmount(): number { return Math.round(this.baseRent * (1 - this.discountRate)); }
  get totalAmount(): number { return this.baseRent - this.discountAmount; }

  async submit(): Promise<void> {
    this.isLoading = true;
    try {
      await orderService.renewOrder(this.orderId, this.selectedMonths);
      router.back();
    } catch (err) { console.error('Renew failed'); }
    this.isLoading = false;
  }

  build() {
    Column() {
      TopAppBar({ title: '续租申请', showBack: true })

      Scroll() {
        Column() {
          // 时长选择
          Text('选择续租时长')
            .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
            .width('100%').margin({ bottom: 16 })

          Row() {
            ForEach([
              { months: 1, label: '1个月', discount: '', price: this.basePrice },
              { months: 3, label: '3个月', discount: '95折', price: Math.round(this.basePrice * 0.95) },
              { months: 6, label: '6个月', discount: '9折', price: Math.round(this.basePrice * 0.9) }
            ], (item: { months: number; label: string; discount: string; price: number }) => {
              Column() {
                Text(item.months.toString())
                  .fontSize(28).fontWeight(FontWeight.Bold)
                  .fontColor(this.selectedMonths === item.months ? $r('app.color.primary') : $r('app.color.on_surface'))
                Text(item.label)
                  .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ top: 4 })
                if (item.discount) {
                  Text(item.discount)
                    .fontSize(9).fontColor($r('app.color.on_secondary'))
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4)
                    .backgroundColor($r('app.color.secondary')).margin({ top: 4 })
                }
              }
              .layoutWeight(1).padding(16).borderRadius(12)
              .backgroundColor(this.selectedMonths === item.months ? 'rgba(46,2,233,0.06)' : $r('app.color.surface_container_lowest'))
              .border({ width: this.selectedMonths === item.months ? 2 : 1, color: this.selectedMonths === item.months ? $r('app.color.primary') : $r('app.color.outline_variant') })
              .margin({ left: item.months > 1 ? 8 : 0 })
              .onClick(() => { this.selectedMonths = item.months; })
            })
          }

          // 费用
          Column() {
            Text('费用明细')
              .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
              .width('100%').margin({ top: 24, bottom: 12 })
            FeeLine({ label: '基础租金 (¥' + this.basePrice + '/月 × ' + this.selectedMonths + '月)', value: '¥' + this.baseRent })
            if (this.discountAmount > 0) {
              FeeLine({ label: '时长折扣', value: '-¥' + this.discountAmount, color: $r('app.color.secondary') })
            }
            Divider().margin({ top: 8, bottom: 8 })
            FeeLine({ label: '合计应付', value: '¥' + this.totalAmount, bold: true, color: $r('app.color.primary') })
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          .margin({ top: 16 })

          Row().height(120)
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      Button('确认续租并支付')
        .width('100%').height(52).borderRadius(14)
        .fontSize($r('app.float.body_lg_font_size')).fontWeight(FontWeight.Bold).fontColor(Color.White)
        .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
        .margin(16)
        .onClick(() => { this.submit(); })
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}

