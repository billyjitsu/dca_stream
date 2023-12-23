"use client";

import Link from "next/link";
import * as React from "react";
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  navigationMenuTriggerStyle,
} from "./ui/navigation-menu"
import { ModeToggle } from "./mode-toggle";

export function Navbar() {
  const navigationOptions = [
    {
      name: "Dashboard",
      href: "/dashboard",
    },
    {
      name: "Wrap / Unwrap",
      href: "/wrap",
    },
    {
      name: "Bridge",
      href: "/bridge",
    },
  ];

  return (
    <div className="flex items-center justify-between p-4">
      <div className="font-bold">Stable Bit Flow</div>
      <NavigationMenu>
        <NavigationMenuList>
          {navigationOptions.map((option) => (
            <NavigationMenuItem>
              <Link href={option.href} passHref>
                <NavigationMenuLink className={navigationMenuTriggerStyle()}>
                  {option.name}
                </NavigationMenuLink>
              </Link>
            </NavigationMenuItem>
          ))}
        </NavigationMenuList>
      </NavigationMenu>
      <div className="flex items-center space-x-[10px]">
        <div>rainbowkit</div>
        <ModeToggle />
      </div>
    </div>
  );
}
