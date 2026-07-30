import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { workOrderService } from '../service/WorkOrderService';
import { MaintenanceOrderVO } from '../model/Models';

/**
 * MaintenanceDetail - 维修进度详情页
 */
@Entry
@Component
struct MaintenanceDetail {
  @State order: MaintenanceOrderVO | null = null;
  @State isLoading: boolean = true;
  private orderId: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    this.orderId = (params?.['id'] as number) || 0;
    this.loadDetail();
  }

  async loadDetail(): Promise<void> {
    try {
      const res = await workOrderService.getDetail(this.orderId);
      if (res.data) this.order = res.data;
    } catch (err) { console.error('Load maintenance detail failed'); }
    this.isLoading = false;
  }

  get steps(): Array<{ title: string; status: string; idx: number }> {
    const all = [
      { title: '已提交', status: 'pending' },
      { title: '已派单', status: 'assigned' },
      { title: '维修中', status: 'repairing' },
      { title: '待验收', status: 'checking' },
      { title: '已完成', status: 'completed' }
    ];
    const currentIdx = all.findIndex(s => s.status === this.order?.status);
    return all.map((s, i) => ({ ...s, idx: i <= currentIdx ? 2 : (i === currentIdx + 1 ? 1 : 0) }));
  }

  build() {
    if (this.isLoading || !this.order) {
      Column() { LoadingProgress().width(40).height(40) }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
      return;
    }

    Column() {
      TopAppBar({ title: '维修详情', showBack: true })

      Scroll() {
        Column() {
          // 工单号
          Text('工单号: ' + this.order!.orderNo)
            .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
            .width('100%').margin({ bottom: 16 })

          // 乐器信息卡片
          Row() {
            Image(this.order!.coverImage || '')
              .width(80).height(80).objectFit(ImageFit.Cover).borderRadius(8)
            Column() {
              Text(this.order!.instrumentName)
                .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
              Text('序列号: ' + (this.order!.serialNo || '-'))
                .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ top: 4 })
              Text('🔧 ' + (this.order!.faultDesc || ''))
                .fontSize($r('app.float.label_sm_font_size'))
                .fontColor($r('app.color.error'))
                .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .backgroundColor('rgba(186,26,26,0.08)')
                .margin({ top: 6 })
            }
            .layoutWeight(1).height(80).margin({ left: 12 }).alignItems(HorizontalAlign.Start)
          }
          .width('100%').padding(16).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })

          // 进度时间轴
          Text('处理进度')
            .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
            .width('100%').margin({ top: 24, bottom: 16 })

          ForEach(this.steps, (step: { title: string; status: string; idx: number }, index: number) => {
            Row() {
              // 左侧状态指示器
              if (step.idx === 2) {
                Text('✓')
                  .fontSize(14).fontColor(Color.White)
                  .width(24).height(24).borderRadius(12)
                  .backgroundColor($r('app.color.primary'))
                  .textAlign(TextAlign.Center)
              } else if (step.idx === 1) {
                Circle()
                  .width(10).height(10).fill($r('app.color.primary'))
                  .border({ width: 3, color: $r('app.color.primary') })
                  .margin({ left: 7 })
              } else {
                Circle()
                  .width(24).height(24)
                  .fill($r('app.color.surface'))
                  .border({ width: 2, color: $r('app.color.outline_variant') })
              }

              // 内容
              Column() {
                Text(step.title)
                  .fontSize(step.idx >= 1 ? $r('app.float.headline_sm_font_size') : $r('app.float.body_md_font_size'))
                  .fontWeight(step.idx >= 1 ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(step.idx >= 1 ? (step.idx === 1 ? $r('app.color.primary') : $r('app.color.on_surface')) : $r('app.color.on_surface_variant'))
              }
              .margin({ left: 12 }).alignItems(HorizontalAlign.Start)
            }
            .width('100%').margin({ top: index > 0 ? 20 : 0 })
            .opacity(step.idx === 0 ? 0.4 : 1.0)
          })
        }
        .padding({ left: 16, right: 16, bottom: 100 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      // 底部操作（根据工单状态动态渲染）
      if (this.order!.status === 'checking') {
        Row() {
          Button('确认验收')
            .layoutWeight(1).height(48).borderRadius(14)
            .fontSize($r('app.float.body_md_font_size')).fontColor(Color.White)
            .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
            .onClick(async () => {
              await workOrderService.confirmRepair(this.orderId);
              this.loadDetail();
            })
        }
        .width('100%').padding(16)
        .backgroundColor('rgba(249,249,255,0.8)').backdropBlur(20)
      } else {
        Row() {
          Button('联系技师')
            .fontSize($r('app.float.body_md_font_size')).fontColor($r('app.color.on_surface_variant'))
            .backgroundColor($r('app.color.surface_container_lowest')).borderRadius(14).height(48)
            .border({ width: 1, color: $r('app.color.outline_variant') })
          Button('在线客服')
            .fontSize($r('app.float.body_md_font_size')).fontColor(Color.White)
            .borderRadius(14).height(48).margin({ left: 12 })
            .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
        }
        .width('100%').padding(16).justifyContent(FlexAlign.End)
        .backgroundColor('rgba(249,249,255,0.8)').backdropBlur(20)
      }
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}
