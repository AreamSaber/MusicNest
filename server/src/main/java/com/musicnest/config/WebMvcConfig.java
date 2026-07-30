package com.musicnest.config;

import com.musicnest.security.AuthInterceptor;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebMvcConfig implements WebMvcConfigurer {

    private final AuthInterceptor authInterceptor;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
                .addPathPatterns("/api/**")
                .excludePathPatterns(
                        "/api/v1/auth/send-code",
                        "/api/v1/auth/login",
                        "/api/v1/auth/huawei-login",
                        "/api/v1/auth/staff-login",
                        "/api/v1/auth/refresh-token",
                        "/api/v1/instruments",            // C端浏览不需登录
                        "/api/v1/instruments/**",
                        "/api/v1/files/*",
                        "/api/v1/admin/check-passwords",
                        "/api/v1/admin/setup-passwords",
                        "/doc.html", "/webjars/**", "/v3/**", "/swagger-ui/**"
                );
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/api/v1/files/**")
                .addResourceLocations("file:./static/uploads/");
    }
}
