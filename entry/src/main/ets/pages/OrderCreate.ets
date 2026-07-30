import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { FeeLine } from '../views/FeeLine';
import { orderService } from '../service/OrderService';
import { instrumentService } from '../service/InstrumentService';
import { UserStore } from '../store/UserStore';
import { InstrumentVO, UserInfo } from '../model/Models';

/**
 * OrderCreate - 下单确认页
 * 进度条（选择→确认→支付）+ 时长选择 + 费用明细 + 信用免押
 */
@Entry
@Component
struct OrderCreate {
  @State instrument: InstrumentVO | null = null;
  @State userInfo: UserInfo | null = null;
  @State selectedMonths: number = 6;
  @State agreedPolicy: boolean = false;
  @State isLoading: boolean = true;
  @State creditFree: boolean = false;
  private instrumentId: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    this.instrumentId = (params?.['instrumentId'] as number) || 0;
    this.userInfo = UserStore.getUserInfo();
    this.creditFree = (this.userInfo?.creditScore || 0) >= 800;
    this.loadInstrument();
  }

  async loadInstrument(): Promise<void> {
    const res = await instrumentService.getDetail(this.instrumentId);
    if (res.data) this.instrument = res.data;
    this.isLoading = false;
  }

  get baseRent(): number { return (this.instrument?.monthlyPrice || 0) * this.selectedMonths; }
  get discountRate(): number {
    if (this.selectedMonths >= 12) return 0.9;
    if (this.selectedMonths >= 6) return 0.95;
    return 1;
  }
  get discountAmount(): number { return Math.round(this.baseRent * (1 - this.discountRate)); }
  get totalAmount(): number { return this.baseRent - this.discountAmount; }
  get deposit(): number { return this.instrument?.deposit || 0; }

  async confirmOrder(): Promise<void> {
    if (!this.agreedPolicy) return;
    // PRD F-07：实名认证通过方可下单
    if (!this.userInfo || this.userInfo.verifyStatus !== 2) {
      // 提示用户先完成实名认证
      AlertDialog.show({
        message: '请先完成实名认证后再租赁',
        confirm: { value: '去认证', action: () => { router.pushUrl({ url: 'pages/VerifyIdCard' }); } },
        cancel: { value: '取消', action: () => {} }
      });
      return;
    }
    try {
      const res = await orderService.createOrder({
        instrumentId: this.instrumentId,
        rentMonths: this.selectedMonths,
        startDate: new Date().toISOString().split('T')[0]
      });
      if (res.code === 200 && res.data) {
        // 模拟支付
        await orderService.payOrder(res.data.id);
        router.replaceUrl({ url: 'pages/OrderDetail', params: { id: res.data.id } });
      }
    } catch (err) {
      console.error('Submit order failed');
    }
  }

  build() {
    if (this.isLoading || !this.instrument) {
      Column() { LoadingProgress().width(40).height(40) }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
      return;
    }

    Column() {
      TopAppBar({ title: '确认订单', showBack: true })

      Scroll() {
        Column() {
          // 进度条
          Row() {
            ForEach(['选择', '确认', '支付'], (step: string, index: number) => {
              Column() {
                Text(index <= 1 ? '✓' : (index + 1).toString())
                  .fontSize(16)
                  .fontColor(index <= 1 ? Color.White : $r('app.color.on_surface_variant'))
                  .width(32).height(32)
                  .borderRadius(16)
                  .backgroundColor(index <= 1 ? $r('app.color.primary') : $r('app.color.surface_container_high'))
                  .textAlign(TextAlign.Center)
                Text(step)
                  .fontSize($r('app.float.label_sm_font_size'))
                  .fontColor(index <= 1 ? $r('app.color.primary') : $r('app.color.on_surface_variant'))
                  .margin({ top: 4 })
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .padding({ top: 8, bottom: 16 })

          // 乐器摘要卡片
          Row() {
            Image(this.instrument!.coverImage || '')
              .width(96).height(96).objectFit(ImageFit.Cover).borderRadius(8)
            Column() {
              Text(this.instrument!.name)
                .fontSize($r('app.float.body_md_font_size')).fontWeight(FontWeight.Bold)
              Text(this.instrument!.brand + ' / ' + (this.instrument!.model || ''))
                .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ top: 4 })
            }
            .layoutWeight(1).height(96).margin({ left: 12 }).alignItems(HorizontalAlign.Start)
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          .margin({ top: 8 })

          // 时长选择
          Text('选择时长')
            .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
            .width('100%').margin({ top: 24, bottom: 12 })

          Row() {
            ForEach([1, 6, 12], (months: number) => {
              Column() {
                Text(months.toString()).fontSize(24).fontWeight(FontWeight.Bold)
                Text('个月').fontSize($r('app.float.body_sm_font_size')).margin({ top: 2 })
                if (months >= 6) {
                  Text(months >= 12 ? '9折' : '推荐')
                    .fontSize(9).fontColor(Color.White)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .borderRadius(4)
                    .backgroundColor($r('app.color.secondary'))
                    .margin({ top: 4 })
                }
              }
              .layoutWeight(1).padding(12).borderRadius(12)
              .backgroundColor(this.selectedMonths === months ? 'rgba(46,2,233,0.08)' : $r('app.color.surface_container_lowest'))
              .border({ width: this.selectedMonths === months ? 2 : 1, color: this.selectedMonths === months ? $r('app.color.primary') : $r('app.color.outline_variant') })
              .margin({ left: months > 1 ? 8 : 0 })
              .onClick(() => { this.selectedMonths = months; })
            })
          }

          // 费用明细
          Column() {
            Text('费用明细')
              .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
              .width('100%').margin({ bottom: 12 })

            FeeLine({ label: '租金总额 (' + this.selectedMonths + '个月)', value: '¥' + this.baseRent.toFixed(2) })
            if (this.discountAmount > 0) {
              FeeLine({ label: '时长折扣', value: '-¥' + this.discountAmount.toFixed(2), color: $r('app.color.secondary') })
            }

            // 信用免押
            if (this.creditFree) {
              Row() {
                Text('🛡️').fontSize(16)
                Text('信用免押')
                  .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.tertiary')).margin({ left: 6 })
                Blank()
                Text('-¥' + this.deposit.toFixed(2))
                  .fontSize($r('app.float.body_md_font_size')).fontWeight(FontWeight.Bold).fontColor($r('app.color.tertiary'))
              }
              .width('100%').padding(12).borderRadius(8)
              .backgroundColor('rgba(0,83,56,0.06)')
              .margin({ top: 8, bottom: 8 })
            } else {
              FeeLine({ label: '设备押金', value: '¥' + this.deposit.toFixed(2) })
            }

            Divider().margin({ top: 8, bottom: 8 })

            Row() {
              Text('应付').fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
              Blank()
              Text('¥' + this.totalAmount.toFixed(2))
                .fontSize($r('app.float.headline_lg_font_size')).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary'))
            }.width('100%')
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          .margin({ top: 16 })

          // 协议
          Row() {
            Checkbox()
              .select(this.agreedPolicy)
              .onChange((value: boolean) => { this.agreedPolicy = value; })
            Text('我已阅读并同意《鸿音管家设备租赁协议》')
              .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ left: 8 })
          }
          .width('100%').margin({ top: 16, bottom: 100 })
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      // 底部确认按钮
      Row() {
        Column() {
          Text('应付金额').fontSize($r('app.float.label_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
          Text('¥' + this.totalAmount.toFixed(2))
            .fontSize($r('app.float.headline_lg_font_size')).fontWeight(FontWeight.Bold).fontColor($r('app.color.primary'))
        }
        Blank()
        Button('确认支付')
          .fontSize($r('app.float.body_lg_font_size')).fontWeight(FontWeight.Bold).fontColor(Color.White)
          .height(52).borderRadius(14)
          .padding({ left: 32, right: 32 })
          .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
          .enabled(this.agreedPolicy)
          .opacity(this.agreedPolicy ? 1 : 0.5)
          .onClick(() => { this.confirmOrder(); })
      }
      .width('100%').padding(16)
      .backgroundColor('rgba(249,249,255,0.8)').backdropBlur(20)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}

