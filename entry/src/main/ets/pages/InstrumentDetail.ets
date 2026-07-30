import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { RatingStars } from '../views/RatingStars';
import { instrumentService } from '../service/InstrumentService';
import { reviewService } from '../service/ReviewService';
import { InstrumentVO, ReviewVO } from '../model/Models';

/**
 * InstrumentDetail - 乐器详情页
 */
@Entry
@Component
struct InstrumentDetail {
  @State instrument: InstrumentVO | null = null;
  @State reviews: ReviewVO[] = [];
  @State selectedPeriod: string = 'monthly';
  @State specsExpanded: boolean = false;
  @State isLoading: boolean = true;
  private instrumentId: number = 0;

  /**
   * 解析 specs JSON 字符串为 [key, value] 数组
   */
  parseSpecs(raw: string): Array<[string, string]> {
    try {
      const obj: Record<string, string> = JSON.parse(raw) as Record<string, string>;
      const result: Array<[string, string]> = [];
      const keys = Object.keys(obj);
      for (let i = 0; i < keys.length; i++) {
        result.push([keys[i], obj[keys[i]]]);
      }
      return result;
    } catch (e) {
      return [['原始数据', raw]];
    }
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    this.instrumentId = (params?.['id'] as number) || 0;
    this.loadDetail();
  }

  async loadDetail(): Promise<void> {
    try {
      const res = await instrumentService.getDetail(this.instrumentId);
      if (res.data) {
        this.instrument = res.data;
      }
      const reviewRes = await reviewService.getList({ instrumentId: this.instrumentId, page: 1, size: 5 });
      if (reviewRes.data) {
        this.reviews = reviewRes.data.records;
      }
    } catch (err) {
      console.error('Load detail failed');
    }
    this.isLoading = false;
  }

  getConditionLabel(level: number): string {
    const labels = ['全新', '95新', '9成新', '8成新', '较旧'];
    return labels[Math.min(level, 5) - 1] || '';
  }

  getPriceForPeriod(): number {
    if (!this.instrument) return 0;
    if (this.selectedPeriod === 'daily') return this.instrument.dailyPrice;
    if (this.selectedPeriod === 'weekly') return this.instrument.weeklyPrice || this.instrument.dailyPrice * 6;
    return this.instrument.monthlyPrice || this.instrument.dailyPrice * 25;
  }

  build() {
    if (this.isLoading) {
      Column() {
        LoadingProgress().width(40).height(40).color($r('app.color.primary_container'))
      }
      .width('100%').height('100%').justifyContent(FlexAlign.Center)
      return;
    }

    if (!this.instrument) {
      Column() {
        Text('乐器信息加载失败').fontColor($r('app.color.error'))
      }
      .width('100%').height('100%').justifyContent(FlexAlign.Center)
      return;
    }

    Column() {
      TopAppBar({ title: '乐器详情', showBack: true, transparent: true })

      Scroll() {
        Column() {
          // 图片区域
          Stack() {
            Image(this.instrument!.coverImage || '')
              .width('100%')
              .aspectRatio(1)
              .objectFit(ImageFit.Cover)
              .borderRadius({ bottomLeft: 16, bottomRight: 16 })

            // 成色标签
            Text(this.getConditionLabel(this.instrument!.conditionLevel))
              .fontSize($r('app.float.label_md_font_size'))
              .fontColor($r('app.color.on_tertiary_container'))
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(16)
              .backgroundColor('rgba(0, 110, 75, 0.9)')
              .position({ x: 16, y: 16 })

            // 图片轮播点
            Row() {
              Circle().width(8).height(8).fill(Color.White).opacity(1)
              Circle().width(8).height(8).fill(Color.White).opacity(0.5).margin({ left: 6 })
              Circle().width(8).height(8).fill(Color.White).opacity(0.5).margin({ left: 6 })
            }
            .position({ x: '50%', y: '95%' })
            .translate({ x: '-50%' })
          }

          // 信息区域
          Column() {
            Text(this.instrument!.brand)
              .fontSize($r('app.float.label_md_font_size'))
              .fontColor($r('app.color.primary'))
              .textTransform(TextTransform.Uppercase)
              .margin({ bottom: 4 })

            Text(this.instrument!.name)
              .fontSize($r('app.float.headline_lg_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_surface'))

            // 评分
            if (this.instrument!.avgRating > 0) {
              Row() {
                RatingStars({ rating: Math.round(this.instrument!.avgRating), starSize: 16 })
                Text(this.instrument!.avgRating.toFixed(1))
                  .fontSize($r('app.float.body_sm_font_size'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFB400')
                  .margin({ left: 4 })
                Text('·')
                  .fontColor($r('app.color.outline_variant'))
                  .margin({ left: 8, right: 8 })
                Text(this.instrument!.reviewCount + ' 条评价')
                  .fontSize($r('app.float.body_sm_font_size'))
                  .fontColor($r('app.color.on_surface_variant'))
              }
              .margin({ top: 8 })
            }
          }
          .width('100%')
          .padding(16)
          .alignItems(HorizontalAlign.Start)

          // 价格阶梯
          Row() {
            ForEach([
              { key: 'daily', label: '日租', price: this.instrument!.dailyPrice },
              { key: 'weekly', label: '周租', price: this.instrument!.weeklyPrice || this.instrument!.dailyPrice * 6 },
              { key: 'monthly', label: '月租', price: this.instrument!.monthlyPrice, best: true }
            ], (item: { key: string; label: string; price: number; best?: boolean }) => {
              Column() {
                Text(item.label)
                  .fontSize($r('app.float.label_sm_font_size'))
                  .fontColor(item.key === this.selectedPeriod ? $r('app.color.on_primary_container') : $r('app.color.on_surface_variant'))
                  .margin({ bottom: 4 })

                Row() {
                  Text('¥')
                    .fontSize($r('app.float.body_sm_font_size'))
                  Text(item.price.toString())
                    .fontSize($r('app.float.headline_sm_font_size'))
                    .fontWeight(FontWeight.Bold)
                }
                .fontColor(item.key === this.selectedPeriod ? Color.White : $r('app.color.on_surface'))

                if (item.best) {
                  Text('BEST VALUE')
                    .fontSize(8)
                    .fontColor(Color.White)
                    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                    .borderRadius(4)
                    .backgroundColor($r('app.color.secondary'))
                    .margin({ top: 4 })
                }
              }
              .layoutWeight(1)
              .padding(12)
              .borderRadius(12)
              .backgroundColor(item.key === this.selectedPeriod ? $r('app.color.primary_container') : $r('app.color.surface_container_lowest'))
              .margin({ left: item.key === 'daily' ? 0 : 8 })
              .onClick(() => { this.selectedPeriod = item.key; })
            })
          }
          .width('100%')
          .padding(16)

          // 规格参数（可展开）
          Column() {
            Row() {
              Text('规格参数')
                .fontSize($r('app.float.headline_sm_font_size'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.on_surface'))

              Blank()

              Text(this.specsExpanded ? '收起 ▲' : '展开 ▼')
                .fontSize($r('app.float.body_sm_font_size'))
                .fontColor($r('app.color.primary'))
            }
            .width('100%')
            .padding(16)
            .onClick(() => { this.specsExpanded = !this.specsExpanded; })

            if (this.specsExpanded && this.instrument!.specs) {
              if (this.instrument!.specs.length > 0) {
                ForEach(this.parseSpecs(this.instrument!.specs), (item: [string, string]) => {
                  Row() {
                    Text(item[0])
                      .fontSize($r('app.float.body_sm_font_size'))
                      .fontColor($r('app.color.on_surface_variant'))
                    Blank()
                    Text(item[1])
                      .fontSize($r('app.float.body_md_font_size'))
                      .fontColor($r('app.color.on_surface'))
                      .fontWeight(FontWeight.Medium)
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })
                  .border({ width: { bottom: 0.5 }, color: $r('app.color.outline_variant') })
                })
              }
            }
          }
          .borderRadius(16)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .margin({ left: 16, right: 16, top: 8 })
          .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })

          // 评价列表
          if (this.reviews.length > 0) {
            Column() {
              Text('用户评价')
                .fontSize($r('app.float.headline_sm_font_size'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.on_surface'))
                .width('100%')
                .padding(16)

              ForEach(this.reviews.slice(0, 3), (review: ReviewVO) => {
                Column() {
                  Row() {
                    Text(review.userNickname || '用户')
                      .fontSize($r('app.float.body_sm_font_size'))
                      .fontWeight(FontWeight.Bold)
                    Blank()
                    RatingStars({ rating: review.rating, starSize: 14 })
                  }
                  .width('100%')

                  Text(review.content)
                    .fontSize($r('app.float.body_sm_font_size'))
                    .fontColor($r('app.color.on_surface_variant'))
                    .margin({ top: 8 })
                    .maxLines(3)
                }
                .width('100%')
                .padding(16)
                .border({ width: { top: 0.5 }, color: $r('app.color.surface_variant') })
              })
            }
            .borderRadius(16)
            .backgroundColor($r('app.color.surface_container_lowest'))
            .margin(16)
            .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
          }

          Row().height(100) // 底部操作栏留白
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部操作栏
      Row() {
        Button('咨询')
          .fontSize($r('app.float.body_md_font_size'))
          .fontColor($r('app.color.on_surface_variant'))
          .backgroundColor($r('app.color.surface_container_low'))
          .borderRadius(24)
          .height(48)
          .width(80)

        Button('立即租赁')
          .fontSize($r('app.float.body_lg_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .layoutWeight(1)
          .height(48)
          .borderRadius(24)
          .margin({ left: 12 })
          .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
          .onClick(() => {
            router.pushUrl({ url: 'pages/OrderCreate', params: { instrumentId: this.instrumentId } });
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('rgba(249,249,255,0.8)')
      .backdropBlur(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}
