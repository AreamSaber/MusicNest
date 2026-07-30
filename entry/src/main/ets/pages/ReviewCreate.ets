import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { RatingStars } from '../views/RatingStars';
import { ImagePicker } from '../views/ImagePicker';
import { reviewService } from '../service/ReviewService';

/**
 * ReviewCreate - 提交评价页
 */
@Entry
@Component
struct ReviewCreate {
  @State rating: number = 0;
  @State content: string = '';
  @State images: string[] = [];
  @State isLoading: boolean = false;
  private orderId: number = 0;
  private type: string = 'rental';
  private instrumentName: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    this.orderId = (params?.['orderId'] as number) || 0;
    this.type = (params?.['type'] as string) || 'rental';
    this.instrumentName = (params?.['instrumentName'] as string) || '';
  }

  get ratingLabels(): string[] { return ['极差', '较差', '一般', '满意', '非常满意']; }

  async submit(): Promise<void> {
    if (this.rating === 0) return;
    this.isLoading = true;
    try {
      await reviewService.createReview({
        rentalOrderId: this.type === 'rental' ? this.orderId : undefined,
        maintenanceOrderId: this.type === 'maintenance' ? this.orderId : undefined,
        type: this.type,
        rating: this.rating,
        content: this.content,
        images: this.images
      });
      router.back();
    } catch (err) { console.error('Submit review failed'); }
    this.isLoading = false;
  }

  build() {
    Column() {
      TopAppBar({ title: '评价', showBack: true })

      Scroll() {
        Column() {
          // 评分区
          Column() {
            Text('为您的体验打分')
              .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })

            RatingStars({
              rating: this.rating,
              interactive: true,
              starSize: 44,
              onChange: (r: number) => { this.rating = r; }
            })

            Text(this.rating > 0 ? this.ratingLabels[this.rating - 1] : '请点击星星评分')
              .fontSize($r('app.float.body_md_font_size'))
              .fontColor(this.rating > 0 ? $r('app.color.primary') : $r('app.color.on_surface_variant'))
              .margin({ top: 8 })
          }
          .width('100%').padding(24).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          .alignItems(HorizontalAlign.Center)

          // 文字评价
          Column() {
            TextArea({ placeholder: '分享您的租赁心得...', text: this.content })
              .height(120).borderRadius(12).padding(12)
              .fontSize($r('app.float.body_md_font_size'))
              .backgroundColor($r('app.color.surface'))
              .border({ width: 1, color: $r('app.color.outline_variant') })
              .onChange((value: string) => { this.content = value; })

            Row() {
              Blank()
              Text(this.content.length + '/500')
                .fontSize($r('app.float.label_sm_font_size')).fontColor($r('app.color.outline_variant'))
            }
            .width('100%').margin({ top: 4 })
          }
          .width('100%').padding(20).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          .margin({ top: 16 })

          // 图片上传
          Column() {
            ImagePicker({
              maxCount: 4,
              images: this.images,
              onChange: (imgs: string[]) => { this.images = imgs; }
            })
          }
          .width('100%').padding(20).borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          .margin({ top: 16 })

          Row().height(120)
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      Button('提交评价')
        .width('100%').height(52).borderRadius(14)
        .fontSize($r('app.float.body_lg_font_size')).fontWeight(FontWeight.Bold).fontColor(Color.White)
        .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
        .margin(16)
        .enabled(this.rating > 0 && !this.isLoading)
        .opacity(this.rating > 0 ? 1 : 0.5)
        .onClick(() => { this.submit(); })
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}
