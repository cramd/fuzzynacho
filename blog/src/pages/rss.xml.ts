import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context: { site: URL | undefined }) {
  const posts = (await getCollection('blog', ({ data }) => data.published !== false)).sort(
    (a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf(),
  );

  return rss({
    title: 'FuzzyNacho Blog',
    description:
      'Thoughts on macrotrends, institutional decay, and tech ecosystems without the corporate sugarcoating.',
    site: context.site ?? 'https://www.fuzzynacho.org',
    items: posts.map((post) => ({
      title: post.data.title,
      description: post.data.description,
      pubDate: post.data.pubDate,
      author: post.data.author,
      link: `/blog/${post.id}`,
      categories: post.data.tags,
    })),
  });
}
