import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { ImagePicker } from '../views/ImagePicker';
import { StatusBadge } from '../views/StatusBadge';
import { workOrderService } from '../service/WorkOrderService';

/**
 * MaintenanceCreate - 报修提交页
 */
@Entry
@Component
struct MaintenanceCreate {
  @State faultDesc: string = '';
  @State faultImages: string[] = [];
  @State urgency: string = 'normal';
  @State isLoading: boolean = false;
  private orderId: number = 0;
  private instrumentId: number = 0;
  private instrumentName: string = '';
  private orderNo: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    this.orderId = (params?.['orderId'] as number) || 0;
    this.instrumentId = (params?.['instrumentId'] as number) || 0;
    this.instrumentName = (params?.['instrumentName'] as string) || '';
    this.orderNo = (params?.['orderNo'] as string) || '';
  }

  async submit(): Promise<void> {
    if (!this.faultDesc.trim()) return;
    this.isLoading = true;
    try {
      const res = await workOrderService.createWorkOrder({
        rentalOrderId: this.orderId,
        instrumentId: this.instrumentId,
        faultDesc: this.faultDesc,
        faultImages: this.faultImages,
        urgency: this.urgency
      });
      if (res.code === 200 && res.data) {
        router.replaceUrl({ url: 'pages/MaintenanceDetail', params: { id: res.data.id } });
      }
    } catch (err) { console.error('Submit maintenance failed'); }
    this.isLoading = false;
  }

  build() {
    Column() {
      TopAppBar({ title: '提交报修', showBack: true })

      Scroll() {
        Column() {
          // 关联订单信息
          Row() {
            Column() {
              Text(this.instrumentName || '关联乐器')
                .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
              if (this.orderNo) {
                Text('订单号: ' + this.orderNo)
                  .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ top: 4 })
              }
            }
            .alignItems(HorizontalAlign.Start).layoutWeight(1)
            StatusBadge({ status: 'renting' })
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })

          // 故障描述
          Text('故障描述 *')
            .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
            .width('100%').margin({ top: 24, bottom: 8 })

          TextArea({ placeholder: '请详细描述乐器出现的故障，例如：琴弦断裂、琴弓损坏、共鸣箱开裂等...', text: this.faultDesc })
            .height(140).borderRadius(12).padding(12)
            .fontSize($r('app.float.body_md_font_size'))
            .backgroundColor($r('app.color.surface_container_lowest'))
            .border({ width: 1, color: $r('app.color.outline_variant') })
            .onChange((value: string) => { this.faultDesc = value; })

          // 照片上传
          Column() {
            ImagePicker({
              maxCount: 5,
              images: this.faultImages,
              onChange: (images: string[]) => { this.faultImages = images; }
            })
          }
          .margin({ top: 24 })

          // 紧急程度
          Text('紧急程度')
            .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
            .width('100%').margin({ top: 24, bottom: 8 })

          Row() {
            UrgencyOption({ label: '普通', icon: 'ℹ️', selected: this.urgency === 'normal', onClick: () => { this.urgency = 'normal'; } })
            UrgencyOption({ label: '紧急', icon: '⚠️', selected: this.urgency === 'urgent', isUrgent: true, onClick: () => { this.urgency = 'urgent'; } })
          }
          .width('100%')

          Row().height(120)
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      // 提交按钮
      Row() {
        Button() {
          Row() {
            if (this.isLoading) LoadingProgress().width(20).height(20).color(Color.White)
            Text('提交报修')
              .fontSize($r('app.float.body_lg_font_size')).fontWeight(FontWeight.Bold)
              .margin({ left: this.isLoading ? 8 : 0 })
          }
        }
        .width('100%').height(52).borderRadius(14).fontColor(Color.White)
        .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
        .enabled(this.faultDesc.trim().length > 0 && !this.isLoading)
        .opacity(this.faultDesc.trim().length > 0 ? 1 : 0.5)
        .onClick(() => { this.submit(); })
      }
      .width('100%').padding(16)
      .backgroundColor('rgba(249,249,255,0.8)').backdropBlur(20)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}

@Component
struct UrgencyOption {
  @Prop label: string = '';
  @Prop icon: string = '';
  @Prop selected: boolean = false;
  @Prop isUrgent: boolean = false;
  onClick?: () => void;

  build() {
    Column() {
      Text(this.icon).fontSize(24)
      Text(this.label)
        .fontSize($r('app.float.body_md_font_size')).fontWeight(FontWeight.Medium)
        .margin({ top: 8 })
        .fontColor(this.selected ? (this.isUrgent ? $r('app.color.error') : $r('app.color.primary')) : $r('app.color.on_surface_variant'))
    }
    .layoutWeight(1).padding(16).borderRadius(12)
    .backgroundColor(this.selected ? (this.isUrgent ? 'rgba(186,26,26,0.06)' : 'rgba(46,2,233,0.06)') : $r('app.color.surface_container_lowest'))
    .border({ width: 1, color: this.selected ? (this.isUrgent ? $r('app.color.error') : $r('app.color.primary')) : $r('app.color.outline_variant') })
    .margin({ left: this.label === '紧急' ? 12 : 0 })
    .onClick(() => { if (this.onClick) this.onClick(); })
  }
}


