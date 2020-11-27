package io.github.jhipster.online.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/content")
public class testController {

    @GetMapping("/hello")
    String hello() {
        return "hello";
    }

    @GetMapping("/content")
    String hello1() {
        return "hello1";
    }
}
