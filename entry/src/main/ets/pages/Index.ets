import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0002;

@Entry
@Component
struct Index {
  @State isLoading: boolean = true;
  @State hasToken: boolean = false;

  aboutToAppear(): void {
    // 启动时检查登录态
    this.checkLoginStatus();
  }

  checkLoginStatus(): void {
    try {
      const token: string | null = AppStorage.get<string>('token');
      if (token && token.length > 0) {
        this.hasToken = true;
        hilog.info(DOMAIN, 'Index', 'Token found, navigating to home');
        // 短暂延迟后跳转首页，避免白屏闪烁
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/MainPage' });
        }, 500);
      } else {
        this.hasToken = false;
        hilog.info(DOMAIN, 'Index', 'No token, navigating to login');
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/Login' });
        }, 500);
      }
    } catch (err) {
      hilog.error(DOMAIN, 'Index', 'Failed to check token: %{public}s', JSON.stringify(err));
      this.hasToken = false;
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      Image($r('app.media.startIcon'))
        .width(80)
        .height(80)
        .margin({ bottom: 16 })
        .opacity(this.isLoading ? 0.6 : 1.0)
        .transition({ type: TransitionType.All, opacity: 0.3 });

      Text('鸿音管家')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary'))
        .opacity(this.isLoading ? 0.6 : 1.0);

      if (this.isLoading) {
        LoadingProgress()
          .width(36)
          .height(36)
          .margin({ top: 24 })
          .color($r('app.color.primary_container'));
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.background'));
  }
}
