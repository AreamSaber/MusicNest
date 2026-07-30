import { router } from '@kit.ArkUI';
import { BottomNavBar } from '../views/BottomNavBar';
import { InstrumentCard } from '../views/InstrumentCard';
import { instrumentService } from '../service/InstrumentService';
import { InstrumentVO } from '../model/Models';

/**
 * MainPage - 主页面（底部四 Tab 容器）
 * Tab: 首页 / 分类 / 订单 / 我的
 */
@Entry
@Component
struct MainPage {
  @State currentTab: number = 0;
  @State hotInstruments: InstrumentVO[] = [];
  @State recommendInstruments: InstrumentVO[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadHomeData();
  }

  async loadHomeData(): Promise<void> {
    try {
      const hotRes = await instrumentService.getHot(4);
      if (hotRes.data) {
        this.hotInstruments = hotRes.data;
      }
      const recRes = await instrumentService.getRecommend();
      if (recRes.data) {
        this.recommendInstruments = recRes.data;
      }
    } catch (err) {
      console.error('Load home data failed');
    }
    this.isLoading = false;
  }

  onTabChange(index: number): void {
    this.currentTab = index;
    if (index === 0) {
      this.loadHomeData();
    }
  }

  // ====== 首页内容 ======
  @Builder
  HomeTab() {
    Scroll() {
      Column() {
        // 搜索栏 + 通知
        Row() {
          Row() {
            Text('🔍')
              .fontSize(16)
              .margin({ left: 12, right: 6 })
            Text('搜索乐器，如：雅马哈钢琴')
              .fontSize($r('app.float.body_sm_font_size'))
              .fontColor($r('app.color.on_surface_variant'))
          }
          .width('80%')
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('app.color.surface_container_low'))
          .onClick(() => {
            router.pushUrl({ url: 'pages/InstrumentList' });
          })

          Button('🔔')
            .fontSize(20)
            .width(40).height(40)
            .backgroundColor(Color.Transparent)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: $r('app.float.container_padding_mobile'), right: $r('app.float.container_padding_mobile'), top: 8, bottom: 4 })

        // Banner 轮播
        Stack() {
          Column() {
            Text('限时特惠')
              .fontSize($r('app.float.label_sm_font_size'))
              .fontColor(Color.White)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(8)
              .backgroundColor('rgba(255,255,255,0.2)')
              .margin({ bottom: 8 })

            Text('首月租金 半价优惠')
              .fontSize($r('app.float.headline_sm_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ bottom: 4 })

            Text('开启你的音乐之旅，优质乐器轻松租')
              .fontSize($r('app.float.body_sm_font_size'))
              .fontColor('rgba(255,255,255,0.85)')

            Button('立即抢租')
              .fontSize($r('app.float.label_md_font_size'))
              .fontColor($r('app.color.primary'))
              .backgroundColor(Color.White)
              .borderRadius(16)
              .height(32)
              .margin({ top: 12 })
          }
          .alignItems(HorizontalAlign.Start)
          .padding(20)
          .align(Alignment.Start)
        }
        .width('90%')
        .height(160)
        .borderRadius(20)
        .linearGradient({
          angle: 135,
          colors: [['#4A3AFF', 0], ['#6B5CFF', 1]]
        })
        .margin({ top: 12, bottom: 8 })

        // 分类宫格
        Grid() {
          ForEach([
            { icon: '🎹', label: '钢琴' },
            { icon: '🎸', label: '吉他' },
            { icon: '🎻', label: '提琴' },
            { icon: '🎷', label: '管乐' },
            { icon: '🪕', label: '民乐' },
            { icon: '🥁', label: '打击乐' },
            { icon: '🎤', label: '配件' },
            { icon: '📋', label: '全部分类' }
          ], (item: { icon: string; label: string }) => {
            GridItem() {
              Column() {
                Text(item.icon).fontSize(28)
                Text(item.label)
                  .fontSize($r('app.float.label_md_font_size'))
                  .fontColor($r('app.color.on_surface'))
                  .margin({ top: 4 })
              }
              .width('100%').height('100%')
              .justifyContent(FlexAlign.Center)
              .borderRadius(12)
              .backgroundColor($r('app.color.surface_container_lowest'))
              .onClick(() => {
                router.pushUrl({ url: 'pages/InstrumentList' });
              })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .width('100%')
        .padding({ left: $r('app.float.container_padding_mobile'), right: $r('app.float.container_padding_mobile') })
        .margin({ top: 12 })

        // 猜你喜欢 - AI推荐
        if (this.recommendInstruments.length > 0) {
          Column() {
            Row() {
              Text('猜你喜欢')
                .fontSize($r('app.float.headline_sm_font_size'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.on_surface'))

              Text('✨ AI推荐')
                .fontSize($r('app.float.label_sm_font_size'))
                .fontColor($r('app.color.primary'))
                .margin({ left: 8 })
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .backgroundColor('rgba(46,2,233,0.08)')
            }
            .width('100%')
            .padding({ left: $r('app.float.container_padding_mobile'), right: $r('app.float.container_padding_mobile') })
            .margin({ top: 24, bottom: 12 })

            Scroll() {
              Row() {
                ForEach(this.recommendInstruments, (item: InstrumentVO, index: number) => {
                  Column() {
                    Stack() {
                      Image(item.coverImage || '')
                        .width(200)
                        .height(130)
                        .objectFit(ImageFit.Cover)
                        .borderRadius(12)

                      Text('AI 推荐')
                        .fontSize(9)
                        .fontColor($r('app.color.on_tertiary_container'))
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(4)
                        .backgroundColor('rgba(0, 110, 75, 0.9)')
                        .position({ x: 8, y: 8 })
                    }

                    Text(item.name)
                      .fontSize($r('app.float.body_sm_font_size'))
                      .fontWeight(FontWeight.Bold)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width(200)
                      .margin({ top: 8 })

                    Text(item.recommendReason || '基于你的偏好')
                      .fontSize(11)
                      .fontColor($r('app.color.on_surface_variant'))
                      .maxLines(1)
                      .width(200)

                    Row() {
                      Text('¥' + item.monthlyPrice)
                        .fontSize($r('app.float.headline_sm_font_size'))
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('app.color.primary'))
                      Text('/月')
                        .fontSize($r('app.float.label_sm_font_size'))
                        .fontColor($r('app.color.on_surface_variant'))
                    }
                    .width(200)
                    .margin({ top: 4 })
                  }
                  .width(210)
                  .padding(10)
                  .borderRadius(16)
                  .backgroundColor($r('app.color.surface_container_lowest'))
                  .shadow({ radius: 12, color: 'rgba(30,41,59,0.05)' })
                  .margin({ right: 12 })
                  .onClick(() => {
                    router.pushUrl({ url: 'pages/InstrumentDetail', params: { id: item.id } });
                  })
                })
              }
              .padding({ left: $r('app.float.container_padding_mobile') })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
          }
        }

        // 热门租赁
        Column() {
          Row() {
            Text('热门租赁')
              .fontSize($r('app.float.headline_sm_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_surface'))

            Blank()

            Text('查看全部 ›')
              .fontSize($r('app.float.body_sm_font_size'))
              .fontColor($r('app.color.on_surface_variant'))
          }
          .width('100%')
          .padding({ left: $r('app.float.container_padding_mobile'), right: $r('app.float.container_padding_mobile') })
          .margin({ top: 24, bottom: 12 })

          Grid() {
            ForEach(this.hotInstruments, (item: InstrumentVO) => {
              GridItem() {
                InstrumentCard({
                  instrumentName: item.name,
                  category: item.category,
                  brand: item.brand,
                  imageUrl: item.coverImage,
                  monthlyPrice: item.monthlyPrice,
                  rating: item.avgRating,
                  status: item.status,
                  conditionLevel: item.conditionLevel
                })
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .width('100%')
          .padding({ left: $r('app.float.container_padding_mobile'), right: $r('app.float.container_padding_mobile') })
        }

        // 底部留白
        Row().height(80)
      }
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }

  // ====== 分类 Tab（内联乐器浏览） ======
  @Builder
  CategoryTab() {
    Column() {
      // 搜索栏
      Row() {
        Row() {
          Text('🔍').fontSize(16).margin({ left: 12, right: 6 })
          Text('搜索乐器...')
            .fontSize($r('app.float.body_sm_font_size'))
            .fontColor($r('app.color.on_surface_variant'))
        }
        .width('80%').height(40).borderRadius(20)
        .backgroundColor($r('app.color.surface_container_low'))
        .onClick(() => { router.pushUrl({ url: 'pages/InstrumentList' }); })
      }
      .width('100%').padding({ left: 16, right: 16, top: 8, bottom: 4 })

      // 筛选 Chip
      Row() {
        ForEach(['钢琴', '吉他', '提琴', '管乐', '民乐', '打击乐'], (f: string) => {
          Text(f).fontSize($r('app.float.label_md_font_size'))
            .fontColor($r('app.color.on_surface_variant'))
            .padding({ left: 12, right: 12, top: 6, bottom: 6 }).borderRadius(16)
            .backgroundColor($r('app.color.surface_variant')).margin({ right: 8 })
        })
      }
      .width('100%').padding({ left: 16, right: 16, top: 4, bottom: 8 })
      .scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

      // 显示首页的热门乐器数据
      Scroll() {
        Column() {
          if (this.hotInstruments.length > 0) {
            ForEach(this.hotInstruments, (item: InstrumentVO) => {
              InstrumentCard({
                instrumentName: item.name, category: item.category, brand: item.brand,
                imageUrl: item.coverImage, monthlyPrice: item.monthlyPrice,
                rating: item.avgRating, status: item.status, conditionLevel: item.conditionLevel
              })
              .margin({ bottom: 12 })
              .onClick(() => { router.pushUrl({ url: 'pages/InstrumentDetail', params: { id: item.id } }); })
            })
          }
          Row().height(80)
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off).layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }

  // ====== 订单 Tab（内联） ======
  @Builder
  OrderTab() {
    Column() {
      Text('我的订单')
        .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
        .width('100%').padding(16)
      Column() {
        Text('📋').fontSize(48)
        Text('查看全部订单')
          .fontSize($r('app.float.body_md_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ top: 8 })
        Button('进入订单列表')
          .margin({ top: 16 })
          .onClick(() => { router.pushUrl({ url: 'pages/OrderList' }); })
      }
      .width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      Row().height(80)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }

  // ====== 我的 Tab（内联） ======
  @Builder
  ProfileTab() {
    Column() {
      Column() {
        Text('👤').fontSize(48).width(72).height(72).borderRadius(36)
          .backgroundColor($r('app.color.surface_container_high')).textAlign(TextAlign.Center).margin({ top: 32 })
        Text('个人中心')
          .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold).margin({ top: 12 })
        Text('查看完整信息').fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).margin({ top: 4 })
        Button('进入个人中心')
          .margin({ top: 16 })
          .onClick(() => { router.pushUrl({ url: 'pages/Profile' }); })
      }
      .width('100%').layoutWeight(1)
      Row().height(80)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }

  build() {
    Stack() {
      // Tab 内容区
      if (this.currentTab === 0) {
        this.HomeTab();
      } else if (this.currentTab === 1) {
        this.CategoryTab();
      } else if (this.currentTab === 2) {
        this.OrderTab();
      } else {
        this.ProfileTab();
      }

      // 底部导航栏
      Column() {
        Blank()
        BottomNavBar({
          activeTab: this.currentTab,
          onChange: (index: number) => {
            this.onTabChange(index);
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}
