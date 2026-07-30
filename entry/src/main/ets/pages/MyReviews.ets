import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { RatingStars } from '../views/RatingStars';
import { reviewService } from '../service/ReviewService';
import { ReviewVO } from '../model/Models';

/**
 * MyReviews - 我的评价列表
 */
@Entry
@Component
struct MyReviews {
  @State reviews: ReviewVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void { this.loadReviews(); }

  async loadReviews(): Promise<void> {
    this.isLoading = true;
    try {
      const res = await reviewService.getList({ page: 1, size: 20 });
      if (res.data) this.reviews = res.data.records;
    } catch (err) { console.error('Load reviews failed'); }
    this.isLoading = false;
  }

  build() {
    Column() {
      TopAppBar({ title: '我的评价', showBack: true })

      if (this.isLoading) {
        Column() { LoadingProgress().width(36).height(36) }
          .width('100%').height('60%').justifyContent(FlexAlign.Center)
      } else if (this.reviews.length === 0) {
        Column() {
          Text('⭐').fontSize(48)
          Text('暂无评价').fontSize($r('app.float.headline_md_font_size')).margin({ top: 12 })
          Text('完成租赁后可以评价').fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
        }
        .width('100%').height('60%').justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.reviews, (review: ReviewVO) => {
            ListItem() {
              Column() {
                Row() {
                  Column() {
                    Text(review.type === 'rental' ? '租赁评价' : '维修评价')
                      .fontSize($r('app.float.label_md_font_size')).fontColor($r('app.color.primary'))
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4)
                      .backgroundColor('rgba(46,2,233,0.06)')
                    RatingStars({ rating: review.rating, starSize: 16 }).margin({ top: 6 })
                  }
                  Blank()
                  Text(review.createdAt || '')
                    .fontSize($r('app.float.label_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
                }.width('100%')

                if (review.content) {
                  Text(review.content)
                    .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant'))
                    .margin({ top: 8 }).maxLines(3)
                }
              }
              .width('100%').padding(16).borderRadius(12)
              .backgroundColor($r('app.color.surface_container_lowest'))
              .margin({ bottom: 10 })
            }
          })
        }
        .layoutWeight(1).padding({ left: 16, right: 16 }).scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}
