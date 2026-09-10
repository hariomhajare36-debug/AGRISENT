package com.agrirent.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Forwards client-side React Router routes to index.html
 * so that fullstack single-container deployments (e.g. Render, Docker)
 * can serve SPAs without 404 errors on direct navigation or refresh.
 */
@Controller
public class SpaForwardController {

    @GetMapping(value = {
        "/",
        "/login",
        "/register",
        "/catalog",
        "/rent",
        "/buy",
        "/how-it-works",
        "/compare",
        "/wishlist",
        "/checkout",
        "/payment",
        "/profile",
        "/equipment/{id}",
        "/farmer/**",
        "/farmer-dashboard",
        "/owner/**",
        "/owner-dashboard",
        "/dealer/**",
        "/dealer-dashboard",
        "/admin/**",
        "/admin-console"
    })
    public String forwardSpa() {
        return "forward:/index.html";
    }
}
