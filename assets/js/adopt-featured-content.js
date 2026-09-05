(function () {
  const updates = [
    {
      href: "/articles/adopt-me-fairytale-castle-notes-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Fairytale Castle",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Fairytale Castle update &mdash; Ballet Swan, prices, and Trading Hub changes",
          excerpt: "Meet the Legendary Ballet Swan, tour the 8,000-Bucks castle and furniture prices, and review every confirmed fix.",
          meta: ["September 4, 2026", "Live update guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Fairytale Castle Notes - Ballet Swan, house prices, and improvements",
          excerpt: "Ballet Swan costs 600 Robux, the castle costs 8,000 Bucks, and Trading Hub listings now accept item offers.",
          meta: ["September 4", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-fairytale-egg-update-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Fairytale Egg",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Fairytale Egg guide &mdash; all 10 pets, exact odds, and hatch chances",
          excerpt: "Meet Pinkypillar, Ms. Muffet, Budgie Witch, Princess Mare, Clumpty, Granny Wolf, Little Lamb, Crimson Cape, Huntsman Robin, and Three Blind Mice.",
          meta: ["August 29, 2026", "Live egg guide"]
        },
        hub: {
          tag: "New Egg",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Fairytale Egg Guide - all 10 pets, odds, and value status",
          excerpt: "Meet Pinkypillar, Ms. Muffet, Budgie Witch, Princess Mare, Clumpty, Granny Wolf, Little Lamb, Crimson Cape, Huntsman Robin, and Three Blind Mice.",
          meta: ["August 29", "Live rotation"]
        }
      }
    },
    {
      href: "/articles/adopt-me-backpack-storage-releaser-refresh-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Backpack Storage",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Backpack Storage guide &mdash; Kiwi Kiwi, Strawberry Tortle, and Storage Tabs",
          excerpt: "The August 21 update adds Backpack Storage, up to 25 Storage Tabs, trading storage access, and two new Legendary Releaser pets.",
          meta: ["August 21, 2026", "Live guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Backpack Storage Guide - Kiwi Kiwi, Strawberry Tortle, and Storage Tabs",
          excerpt: "Open the August 21 guide for Backpack Storage, Storage Tabs, trading storage access, and the two new Legendary Releaser pets.",
          meta: ["August 21", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-stray-case-notes-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Stray Case Notes",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Stray Case Notes guide &mdash; Chihuahua, Tuxedo Cat, and Trading Hub fixes",
          excerpt: "The August 14 update adds Chihuahua, Tuxedo Cat, a daily Mysterious Stranger task, new pet wear, and Trading Hub cleanup.",
          meta: ["August 14, 2026", "Live guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Stray Case Notes Guide - Chihuahua, Tuxedo Cat, and Trading Hub fixes",
          excerpt: "Open the August 14 guide for the daily fork delivery task, both new pets, the pet wear list, and the Trading Hub cleanup pass.",
          meta: ["August 14", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-9th-birthday-party-notes-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Birthday Party",
          badgeLabel: "New",
          badgeTone: "new",
          title: "9th Birthday Party Notes guide &mdash; 2026 Birthday Butterfly, Cake Friend, and Silverback Gorilla",
          excerpt: "The August 7 update adds the 2026 Birthday Butterfly, Cake Friend, birthday pet wear, Silverback Gorilla ticket exchange access, and Trading Hub improvements.",
          meta: ["August 7, 2026", "Live guide"]
        },
        hub: {
          tag: "Birthday Update",
          badgeLabel: "New",
          badgeTone: "new",
          title: "9th Birthday Party Notes Guide - 2026 Birthday Butterfly, Cake Friend, and Silverback Gorilla",
          excerpt: "Open the August 7 guide for the birthday pet lineup, Silverback Gorilla ticket exchange access, birthday pet wear, and Trading Hub fixes.",
          meta: ["August 7", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-bee-pass-notes-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Bee Pass",
          badgeLabel: "Updated",
          badgeTone: "updated",
          title: "Bee Pass Notes guide &mdash; Sunflower Friend, Violet Friend, seed costs, and the extra week",
          excerpt: "The July 24 update stays live for another week after Trading Hub Notes, with Sunflower Friend and Violet Friend still active in the current pass loop.",
          meta: ["July 24, 2026", "Updated guide"]
        },
        hub: {
          tag: "Previous Update",
          badgeLabel: "Updated",
          badgeTone: "updated",
          title: "Bee Pass Notes Guide - Sunflower Friend, Violet Friend, bouquet XP, and the extra week",
          excerpt: "Open the July 24 guide for flower seed prices, Bee Pass rewards, the Beehive House, and the official extra-week note.",
          meta: ["July 24", "Updated guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-journey-through-skies-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Journey Through Skies",
          badgeLabel: "Today",
          badgeTone: "new",
          title: "Journey Through Skies guide &mdash; Pilot Gull, airship feathers, and Sheepdog Ducky",
          excerpt: "The June 12 update adds Pilot Gull for 6,900 Compass Coins, the airship feather activity, three flight pet wear items, and a June 13 Sheepdog Ducky Admin Abuse debut.",
          meta: ["June 12, 2026", "Live guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "Today",
          badgeTone: "new",
          title: "Journey Through Skies Guide - Pilot Gull, feathers, and Sheepdog Ducky",
          excerpt: "Open the live June 12 guide for Pilot Gull, the airship activity, Compass Coin prices, flight pet wear, Sheepdog Ducky timing, and value-status notes.",
          meta: ["June 12", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-journey-to-summer-camp-week-1-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Journey to Summer Camp",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Journey to Summer Camp Week 1 guide &mdash; Bison, Ranger Beaver, and Compass Coins",
          excerpt: "The May 29 update adds Beaver Bob's van activity, Compass Coins, the one-week Rare Bison, the 99 Robux Ranger Beaver bundle, and market-forming value notes.",
          meta: ["May 29, 2026", "Live guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Journey to Summer Camp Week 1 Guide - Bison, Ranger Beaver, and Compass Coins",
          excerpt: "Open the May 29 guide for Bison, Ranger Beaver, Beaver Bob's van activity, Compass Coin spending, bug fixes, and value status.",
          meta: ["May 29", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-stormy-ducky-drama-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Stormy Ducky Drama",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Stormy Ducky Drama guide &mdash; Rubber Ducky Box odds, Shadow Dragon Ducky, and storm rewards",
          excerpt: "The May 22-23 update wave adds Rubber Ducky, Glyptodon Ducky, Unicorn Ducky, Strawberry Shortcake Ducky, Shadow Dragon Ducky, Dirty Ducky, a storm task, and live value notes.",
          meta: ["May 22, 2026", "Live guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Stormy Ducky Drama Guide - Rubber Ducky Box odds and Shadow Dragon Ducky",
          excerpt: "Open the May 22-23 guide for Rubber Ducky, Glyptodon Ducky, Unicorn Ducky, Strawberry Shortcake Ducky, Shadow Dragon Ducky, Dirty Ducky, storm rewards, and live value notes.",
          meta: ["May 22", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-tims-trial-tonics-potion-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Tim's Trial Tonics",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Tim's Trial Tonics guide &mdash; potion recipes, ingredients, and what to craft first",
          excerpt: "The May 15 update adds a one-week potion crafting event with three temporary ingredients, Tim's cauldron, 10 potion effects, and no new pets to value this week.",
          meta: ["May 15, 2026", "Live guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "New",
          badgeTone: "new",
          title: "Tim's Trial Tonics Guide - potion recipes, ingredients, and event timing",
          excerpt: "Farm ingredients from pet needs and taskboard quests, then brew 10 temporary potion effects. The May 15 update is a potion event, not a new-pet drop.",
          meta: ["May 15", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-new-weather-needs-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "New Weather Needs",
          badgeLabel: "Pinned",
          badgeTone: "updated",
          title: "New Weather Needs guide &mdash; weather-exclusive needs, the Super Age-Up Potion, and profile saves",
          excerpt: "The May 8 update adds four weather-exclusive pet needs, a one-week Super Age-Up Potion, profile saving, a permanent countdown bell, and a fresh wave of quality-of-life upgrades.",
          meta: ["May 8, 2026", "Live guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "New",
          badgeTone: "new",
          title: "New Weather Needs Guide - weather-exclusive needs, Super Age-Up Potion, profile saves",
          excerpt: "The May 8 update is mostly about how the game feels to play. Weather-exclusive needs, a Super Age-Up Potion, profile saving, the new countdown bell, and quality-of-life upgrades in one guide.",
          meta: ["May 8", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-salon-revamp-moonbeam-peacock-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Salon Revamp",
          badgeLabel: "Pinned",
          badgeTone: "updated",
          title: "Salon Revamp guide &mdash; Moonbeam Peacock, Peahen, Peachick, and the Golden Dandelion",
          excerpt: "The May 1 update redesigns the salon and adds three new peacock-family pets. See the official Golden Dandelion drop rates, the new soap system, and the temporary neckerchief rewards.",
          meta: ["May 1, 2026", "Live guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "Pinned",
          badgeTone: "updated",
          title: "Salon Revamp Guide - Moonbeam Peacock, Peahen, Peachick, and the Golden Dandelion",
          excerpt: "The May 1 update brings three new peacock pets via the Golden Dandelion treat, redesigns the salon, and adds a portable soap system. Here is the cleaned-up update guide.",
          meta: ["May 1", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-seans-sale-item-releaser-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Sean's Sale",
          badgeLabel: "Pinned",
          badgeTone: "updated",
          title: "Sean's Sale guide &mdash; Glormy Crab, the Item Releaser, and the Final Stop Shop",
          excerpt: "The April 24 update brings Glormy Crab as a Legendary Ticket buy, a brand-new Item Releaser inside Sean's UFO, a 2x XP and Bucks loop, Mega Neon Paint rotation, and a Final Stop Shop clearance pass.",
          meta: ["April 24, 2026", "Live guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "Pinned",
          badgeTone: "updated",
          title: "Sean's Sale Guide - Glormy Crab, Item Releaser, and Final Stop Shop",
          excerpt: "The April 24 update is Sean's biggest week yet. Glormy Crab, the new Item Releaser, the UFO 2x loop, Mega Neon Paint rotation, and the Final Stop Shop in one cleaned-up guide.",
          meta: ["April 24", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-birthday-magic-purrowl-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Birthday Magic",
          badgeLabel: "Pinned",
          badgeTone: "updated",
          title: "Purrowl guide &mdash; how birthday gifts work and the smartest pets to level first",
          excerpt: "The April 17 update turns aging into a new reward loop. See what the official notes confirm about Purrowl, birthday gifts, and why high-needs pets are the best chase lane.",
          meta: ["April 17, 2026", "Live guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "Pinned",
          badgeTone: "updated",
          title: "Birthday Magic Guide - Purrowl, birthday gifts, and the best leveling strategy",
          excerpt: "The April 17 update turns aging into a reward chase. See what the official notes confirm about Purrowl, birthday gifts, and why high-needs pets are the strongest lane.",
          meta: ["April 17", "Live guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-sugarfest-candy-egg-spend-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Sugarfest Final Weekend",
          badgeLabel: "Pinned",
          badgeTone: "updated",
          title: "1.2x Candy Eggs Weekend Guide &mdash; what to buy now, what can wait for the wagon",
          excerpt: "Today&apos;s real update is the 1.2x Candy Eggs weekend. See the exact Sugarfest timeline, every Candy Egg spend option, and the smartest way to use your balance before April 17.",
          meta: ["April 10, 2026", "Weekend guide"]
        },
        hub: {
          tag: "Weekly Update",
          badgeLabel: "Pinned",
          badgeTone: "updated",
          title: "1.2x Candy Eggs Weekend Guide - full spend plan before the wagon closes",
          excerpt: "Today&apos;s Sugarfest update is the final weekend boost. See what changes on April 13, what stays until April 17, and how to spend Candy Eggs smartly.",
          meta: ["April 10", "Weekend guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-sugarfest-week4-chocolate-bunny-guide.html",
      featured: true,
      contexts: {
        home: {
          tag: "Update Archive",
          badgeLabel: "Pinned",
          badgeTone: "updated",
          title: "Sugarfest Week 4 Archive - Milk, White, and Dark Choccybunny plus Pupcake",
          excerpt: "The final Sugarfest snapshot keeps Pupcake, Milk Choccybunny, White Choccybunny, Dark Choccybunny, release framing, and end-of-event context in one clean archive page.",
          meta: ["April 2026 archive", "Week 4 finale"]
        },
        hub: {
          tag: "Weekly Update",
          title: "Sugarfest Week 4 Guide - Choccybunny Box, Pupcake, and Easter Bunny finale",
          excerpt: "A clean recap of the final Sugarfest drop, including Pupcake, Milk Choccybunny, White Choccybunny, and Dark Choccybunny.",
          meta: ["Week 4", "Featured update"]
        }
      }
    },
    {
      href: "/articles/adopt-me-sugarfest-jerboa-jam-guide.html",
      contexts: {
        home: {
          tag: "Update Archive",
          title: "Sugarfest Week 3 Archive - Jerboa Jam, Latte Kitsune, and Jiggly Jerboa",
          excerpt: "Week 3 stays easy to revisit for late-event traders who want the original Jerboa Jam context and pet rollout summary.",
          meta: ["March 2026 archive", "Week 3 guide"]
        },
        hub: {
          tag: "Weekly Update",
          title: "Sugarfest Week 3 Archive - Jerboa Jam, Latte Kitsune, and Jiggly Jerboa",
          excerpt: "Jerboa Jam covers Latte Kitsune, Jiggly Jerboa, and the late-event pets players still revisit in the archive.",
          meta: ["Week 3", "Update guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-sugarfest-waffle-scuffle-guide.html",
      contexts: {
        home: {
          tag: "Update Archive",
          title: "Sugarfest Week 2 Archive - Mochi Meow, Waffle Wyrm, and the Waffle Scuffle minigame",
          excerpt: "The Week 2 snapshot is still one of the best examples of how a minigame and a premium pet changed event pacing.",
          meta: ["March 2026 archive", "Week 2 guide"]
        },
        hub: {
          tag: "Weekly Update",
          title: "Sugarfest Week 2 Archive - Mochi Meow, Waffle Wyrm, and Waffle Scuffle",
          excerpt: "A quick stop for Mochi Meow, Waffle Wyrm, and the mid-event minigame changes players still look up.",
          meta: ["Week 2", "Archive guide"]
        }
      }
    },
    {
      href: "/articles/adopt-me-sugarfest-2026.html",
      contexts: {
        home: {
          tag: "Event Guide",
          title: "Sugarfest 2026 Archive - kickoff guide, pets, and event structure",
          excerpt: "Use the cleaned event overview as the anchor page when you want the whole Sugarfest story in one place before diving into each week.",
          meta: ["Event overview", "Sugarfest hub"]
        },
        hub: {
          tag: "Event Guide",
          title: "Sugarfest 2026 Archive - kickoff guide, pets, and event overview",
          excerpt: "A top-level Sugarfest recap for players who want the launch pets, minigames, and weekly links in one place.",
          meta: ["Event overview", "Archive guide"]
        }
      }
    }
  ];

  const heroCtas = {
    home: {
      href: updates[0].href,
      labelHtml: "Read the Fairytale Castle guide &#8594;"
    },
    hub: {
      href: updates[0].href,
      labelHtml: "Open Fairytale Castle guide &#8594;"
    }
  };

  function getContext(update, context) {
    return update.contexts[context] || update.contexts.home;
  }

  function getBadgeMarkup(copy) {
    if (!copy.badgeLabel) {
      return "";
    }

    const badgeClass = copy.badgeTone === "updated" ? "badge-updated" : "badge-new";
    return ` <span class="${badgeClass}">${copy.badgeLabel}</span>`;
  }

  function getMetaMarkup(meta) {
    const first = meta && meta[0] ? meta[0] : "";
    const second = meta && meta[1] ? meta[1] : "";

    if (first && second) {
      return `<span>${first}</span><span>&#183;</span><span>${second}</span>`;
    }

    if (first) {
      return `<span>${first}</span>`;
    }

    return `<span>Update coverage</span>`;
  }

  function renderCards(containerId, context, trackLocation) {
    const container = document.getElementById(containerId);
    if (!container) {
      return;
    }

    container.innerHTML = updates.map((update) => {
      const copy = getContext(update, context);
      const featuredClass = update.featured ? " article-card-featured" : "";
      return `
        <a href="${update.href}" class="article-card${featuredClass}" data-track-event="article_tile_click" data-track-location="${trackLocation}">
          <div class="card-game-tag am">${copy.tag}${getBadgeMarkup(copy)}</div>
          <h3 class="card-title">${copy.title}</h3>
          <p class="card-excerpt">${copy.excerpt}</p>
          <div class="card-meta">${getMetaMarkup(copy.meta)}</div>
        </a>
      `;
    }).join("");
  }

  function applyHeroCta(elementId, config, trackEvent, trackLocation) {
    const cta = document.getElementById(elementId);
    if (!cta || !config) {
      return;
    }

    cta.href = config.href;
    cta.innerHTML = config.labelHtml;
    if (trackEvent) {
      cta.dataset.trackEvent = trackEvent;
    }
    if (trackLocation) {
      cta.dataset.trackLocation = trackLocation;
    }
  }

  function renderHomepage() {
    applyHeroCta("home-hero-primary-cta", heroCtas.home, "homepage_cta_click", "hero_primary");
    renderCards("homepage-latest-updates", "home", "weekly_rotation");
  }

  function renderGuidesHub() {
    applyHeroCta("hub-hero-primary-cta", heroCtas.hub, "hub_cta_click", "hero_latest");
    renderCards("hub-current-rotation", "hub", "hub_rotation");
  }

  window.ThePatchFeaturedContent = {
    heroCtas,
    updates,
    renderHomepage,
    renderGuidesHub
  };
})();
